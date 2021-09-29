Li Zheng <flyskywhy@gmail.com>

# Ali SmartLiving 使用详解
[阿里云生活物联网平台](https://living.aliyun.com/)

## 安装设备端编译环境
由于 Ubuntu 用来编译 alios 的工具 aos 只能通过 python3 相关的组件 python3-pip 来安装，而 ali-smartliving-device-alios-things 中一些官方提供的 python 脚本仍然是 python2 语法的，所以需要如下罗嗦的方法来安装编译环境，而非仅仅只是安装 aos 即可。

### 安装 python 和 aos

    sudo apt-get install python2 python3 python3-pip
    pip3 install aos-cube

### 让 python 脚本运行在 python2 中
如果通过如下命令

    ls -l /usr/bin/python

发现

    /usr/bin/python -> python3

则

    cd /usr/bin
    sudo ln -f -s python2 python

否则编译时会出现 `NameError: name 'file' is not defined` 等错误。

### 让 aos 运行在 python3 中
用文本编辑器打开 `~/.local/bin/aos` ，确保第一行是 `#!/usr/bin/python3` 。

否则编译时会出现 `ImportError: No module named aos.__main__` 错误。

### 其它
我也曾想要通过简单将脚本从 python2 升级到 python3 语法来解决 `NameError: name 'file' is not defined` 等错误，但是又带来了其它语法问题，这已经不是我们而是 sdk 提供者需要再花时间在上面了，还是如上所述安装 python2 吧。之前听说 python 2 和 3 不兼容因而我一直拒绝深入学习使用 python ，果然 python 就是差劲啊，开源世界还不如将用到 python 的地方都切换为 nodejs 呢。

注，上述简单将 python2 的 `file` 改为 python3 的 `open` 后，还会出现如下报错信息：

    Traceback (most recent call last):
      File "tools/bk7231u/gen_firmware_img_uart0.py", line 39, in <module>
        pack_image(sys.argv[1], sys.argv[2])
      File "tools/bk7231u/gen_firmware_img_uart0.py", line 30, in pack_image
        f.write("\xff")
    TypeError: a bytes-like object is required, not 'str'

## 设备端编译 Ali SmartLiving
参见 `ali-smartliving-device-alios-things/README.md` 中 `build.sh` 的使用方法。

## 设备端添加 WebSocket Server 支持
添加 WebSocket Server 之后，就可以配合模块厂商（不是阿里官方）的 WiFi 热点代码，让 APP 直连控制设备，而无需
Ali SmartLiving 官方的扫描、配网、控制设备流程，无需烧录产品 id 等三元组信息，因此也就无需向阿里购买这些三元组（因为直连模式不走阿里云生活物联网平台也能用），甚至无需烧录可能也要花钱购买的 mac 地址！之所以使用 WebSocket 而非传统的 Socket ，是因为浏览器不支持创建 Socket 连接，而使用 WebSocket 的话，(react-native 和 react-native-web 同一套代码编写的)手机版或网页版 APP 都可以进行连接。

之所以在 [Comparison of WebSocket implementations](https://en.wikipedia.org/wiki/Comparison_of_WebSocket_implementations) 中选择 libwebsockets 而非 noPoll 等 C 语言 WebSocket 实现，是因为 Ali SmartLiving 所依赖的 [AliOS-Things](https://github.com/alibaba/AliOS-Things) 曾经采用过一段时间的 libwebsockets ，所以可以参考当时的阿里官方适配代码。

以下列出针对 Ali SmartLiving 的飞燕 SDK 1.6.0 添加 WebSocket Server 支持的方法

### 添加 libwebsockets 的第 1 步: 简单复制 https://github.com/warmcat/libwebsockets/tree/v2.4.1/lib/ 整个目录
将该 `lib/` 目录复制为 `Living_SDK/framework/libwebsockets/` 。之所以选择 `v2.4.1` ，是因为经比较发现，阿里官方曾经适配过的 libwebsockets 代码就是这个版本的。

### 添加 libwebsockets 的第 2 步: 复制阿里官方的适配代码，来自 https://github.com/alibaba/AliOS-Things/commit/9326fc864c282e6c3209b2fd00082b451effa54e
将该提交点中新增的文件复制到 `Living_SDK/framework/libwebsockets/` 中。

### 添加 libwebsockets 的第 3 步: 在你自己的代码中使用 libwebsockets 并开启 websocket server

#### Living_SDK/framework/libwebsockets/libwebsockets.mk
将 `Living_SDK/framework/libwebsockets/websockets.mk` 重命名为 `libwebsockets.mk` ，并做如下修改
```
@@ -1,17 +1,16 @@
-NAME := websockets
+NAME := libwebsockets

 GLOBAL_CFLAGS += -Wall

-$(NAME)_COMPONENTS := mbedtls alicrypto connectivity.websockets.mbedtls_wrapper
+$(NAME)_COMPONENTS := imbedtls alicrypto libwebsockets.mbedtls_wrapper

 $(NAME)_SOURCES := handshake.c libwebsockets.c service.c pollfd.c output.c context.c alloc.c header.c ssl.c

 $(NAME)_SOURCES += misc/base64-decode.c misc/lws-ring.c misc/lws-genhash.c misc/sha-1.c

-#$(NAME)_SOURCES += server/ranges.c server/server.c server/parsers.c server/ssl-server.c server/server-handshake.c
-$(NAME)_SOURCES += server/parsers.c
+$(NAME)_SOURCES += server/server.c server/parsers.c server/ssl-server.c server/server-handshake.c

-$(NAME)_SOURCES += client/client.c client/client-handshake.c client/client-parser.c client/ssl-client.c
+# $(NAME)_SOURCES += client/client.c client/client-handshake.c client/client-parser.c client/ssl-client.c
```

#### Living_SDK/framework/libwebsockets/lws_config.h
```
@@ -75,10 +75,10 @@
 #define LWS_NO_DAEMONIZE

 /* Build without server support */
-#define LWS_NO_SERVER
+/* #undef LWS_NO_SERVER */

 /* Build without client support */
-/* #undef LWS_NO_CLIENT */
+#define LWS_NO_CLIENT
```

#### Living_SDK/framework/libwebsockets/mbedtls_wrapper/mbedtls_wrapper.mk
```
-$(NAME)_COMPONENTS := mbedtls alicrypto
+$(NAME)_COMPONENTS := imbedtls alicrypto
```

#### Living_SDK/framework/libwebsockets/sync.py
```
-sync = False #do not sync this module
+# sync = False #do not sync this module
```

#### Products/example/YourAPP/YourAPP.mk
```
 $(NAME)_COMPONENTS += framework/protocol/linkkit/sdk \
                       framework/protocol/linkkit/hal \
                       framework/netmgr \
+                      framework/libwebsockets \
                       framework/common \
                       utility/cjson \
                       framework/uOTA
```

#### Products/example/YourAPP/makefile
```
@@ -14,6 +14,9 @@ INCLUDE      = $(INCLUDE_PATH)/ \
                -I$(PWD)/../../../prebuild/include/platform/arch/arm/armv7m/gcc/m4 \
                -I$(PWD)/../../../prebuild/include/board/$(BOARD) \
                -I$(PWD)/../../../Living_SDK/kernel/protocols/net/include \
+               -I$(PWD)/../../../Living_SDK/security/imbedtls/include \
+               -I$(PWD)/../../../Living_SDK/framework/libwebsockets \
+               -I$(PWD)/../../../Living_SDK/framework/libwebsockets/mbedtls_wrapper/include \
                -I$(PWD)/../../../Living_SDK/platform/mcu/bk7231u/beken/alios/entry \
                -I$(PWD)/../../../Living_SDK/platform/mcu/bk7231u/beken/alios/lwip-2.0.2/port \
                -I$(PWD)/../../../Living_SDK/platform/mcu/bk7231u/beken/common \
```

#### Products/example/YourAPP/softap.c
```
#include <lwip/sockets.h>

#include <libwebsockets.h>
#define LWS_PLUGIN_STATIC

#include "aos/kv.h"

#define SOCK_IN_PORT 7681

typedef void*(*property_rw_func)(const char *request, const int request_len);
property_rw_func softap_property_setting_cb = 0;

static unsigned char softap_flag = 0;
static bool softap_launch = false;
static bool connected = false;

void SetSoftApPropertySettingHandle(void* cb)
{
    if(cb != NULL){
        softap_property_setting_cb = cb;
    }
}

#define MAX_TX_MSG_LEN 200
struct msg {
    char payload[MAX_TX_MSG_LEN];
    size_t len;
};

struct msg amsg; /* the one pending message... */

struct per_session_data__minimal {
    struct per_session_data__minimal *pss_list;
    struct lws *wsi;
};

struct per_session_data__minimal *websocket_pss_list; /* linked-list of live pss*/

void softap_msg_response_handle(char* msg, int len)
{
    if (len + LWS_PRE > MAX_TX_MSG_LEN) {
        LOG("[SoftAP] tx msg is to big");
        return;
    }

    amsg.len = len;
    memcpy((char *)amsg.payload + LWS_PRE, msg, len);

    lws_start_foreach_llp(struct per_session_data__minimal **,
                  ppss, websocket_pss_list) {
        lws_callback_on_writable((*ppss)->wsi);
    } lws_end_foreach_llp(ppss, pss_list);
}

static void softap_property_setting_handle(const char* buffer, int len)
{
    if(softap_property_setting_cb != NULL){
        softap_property_setting_cb(buffer, len);
    }
}

bool softap_isstart(void){
    return softap_launch;
}

void softap_task_stop(void){
    softap_launch = false;
}

void softap_task_start(void){
    softap_launch = true;
}

#define lws_ll_fwd_insert(\
    ___new_object,  /* pointer to new object */ \
    ___m_list,  /* member for next list object ptr */ \
    ___list_head    /* list head */ \
        ) {\
        ___new_object->___m_list = ___list_head; \
        ___list_head = ___new_object; \
    }

#define lws_ll_fwd_remove(\
    ___type,    /* type of listed object */ \
    ___m_list,  /* member for next list object ptr */ \
    ___target,  /* object to remove from list */ \
    ___list_head    /* list head */ \
    ) { \
                lws_start_foreach_llp(___type **, ___ppss, ___list_head) { \
                        if (*___ppss == ___target) { \
                                *___ppss = ___target->___m_list; \
                                break; \
                        } \
                } lws_end_foreach_llp(___ppss, ___m_list); \
    }

// ref to
// https://libwebsockets.org/lws-api-doc-v2.4-stable/html/md_READMEs_README_8coding.html
// https://github.com/warmcat/libwebsockets/blob/main/minimal-examples-lowlevel/ws-server/minimal-ws-server/protocol_lws_minimal.c
static int
callback_smartliving(struct lws *wsi, enum lws_callback_reasons reason,
            void *user, void *in, size_t len)
{
    struct per_session_data__minimal *pss =
            (struct per_session_data__minimal *)user;

    int m;

    LOGD("LWS_CALLBACK %d", reason);
    switch (reason) {
    case LWS_CALLBACK_PROTOCOL_INIT:
        break;

    case LWS_CALLBACK_ESTABLISHED:
        /* add ourselves to the list of live pss held in the global variable */
        lws_ll_fwd_insert(pss, pss_list, websocket_pss_list);
        pss->wsi = wsi;

        if (connected) {
            // maybe your APP only allow 1 connection?
            // TODO: allow more than 1 connection?
            LOG("only one connection is allowed\n");
            lws_close_reason(wsi, LWS_CLOSE_STATUS_UNEXPECTED_CONDITION,
                     (unsigned char *)"only one", 5);
            return -1;
        } else {
            connected = true;
            LOG("websocket established\n");
        }
        break;

    case LWS_CALLBACK_CLOSED:
        /* remove our closing pss from the list of live pss */
        lws_ll_fwd_remove(struct per_session_data__minimal, pss_list,
                  pss, websocket_pss_list);

        connected = false;
        LOG("websocket closed\n");
        break;

    case LWS_CALLBACK_SERVER_WRITEABLE:
        if (!amsg.payload)
            break;

        /* notice we allowed for LWS_PRE in the payload already */
        m = lws_write(wsi, ((unsigned char *)amsg.payload) +
                  LWS_PRE, amsg.len, LWS_WRITE_TEXT);
        if (m < (int)amsg.len) {
            LOG("ERROR %d writing to ws\n", m);
            // lwsl_err("ERROR %d writing to ws\n", m);
            return -1;
        }
        break;

    case LWS_CALLBACK_RECEIVE:
        if(len <= 0){
            return -1;
        }
        LOG("[SoftAP]recv data = [%d]%s\n", len, (const char *)in);
        softap_property_setting_handle((const char *)in, len);
        break;

    default:
        break;
    }

    return 0;
}

static struct lws_protocols protocols[] = {
    // { "http", lws_callback_http_dummy, 0, 0 },
    {
        "local-ali-smartliving",
        callback_smartliving,
        sizeof(struct per_session_data__minimal),
        200,
        0, NULL, 0
    },
    { NULL, NULL, 0, 0 } /* terminator */
};

static void websocket_server(void)
{
    struct lws_context_creation_info info;
    struct lws_context *context;
    const char *p;
    int n = 0, logs = LLL_USER | LLL_ERR | LLL_WARN | LLL_NOTICE
            /* for LLL_ verbosity above NOTICE to be built into lws,
             * lws must have been configured and built with
             * -DCMAKE_BUILD_TYPE=DEBUG instead of =RELEASE */
            /* | LLL_INFO */ /* | LLL_PARSER */ /* | LLL_HEADER */
            /* | LLL_EXT */ /* | LLL_CLIENT */ /* | LLL_LATENCY */
            /* | LLL_DEBUG */;

    lws_set_log_level(logs, NULL);

    memset(&info, 0, sizeof info); /* otherwise uninitialized garbage */
    info.port = SOCK_IN_PORT;
    info.protocols = protocols;
    info.max_http_header_pool = 5;
    // info.vhost_name = "localhost";
    // info.options =
    //     LWS_SERVER_OPTION_HTTP_HEADERS_SECURITY_BEST_PRACTICES_ENFORCE;
    info.options = LWS_SERVER_OPTION_VALIDATE_UTF8;

    // info.ip_limit_ah = 3;
    // info.ip_limit_wsi = 5;

    context = lws_create_context(&info);
    if (!context) {
        LWIP_ASSERT("[SoftAP]WebSocket bind failed.", 0);
        // return;
    }

    LOG("[SoftAP]enter websocket_server loop");
    while (true)
    {
        while(!softap_launch){
            aos_msleep(1000);
        }

        n = lws_service(context, 50);
    }

    lws_context_destroy(context);

    LOG("[SoftAP]exit soft ap task");
    aos_task_exit(0);
}

void softap_task(void)
{
    LOG("[SoftAP]enter soft ap task");
    websocket_server();
}


int init_softap_flag()
{
    unsigned char value;
    int ret, len = sizeof(value);

    ret = aos_kv_get("soft ap flag", &value, &len);
    if (ret == 0 && len > 0) {
        softap_flag = value;
        LOG("soft ap flag = %d", (int)value);
    }else{
        LOG("soft ap get err ret = %d", ret);
        softap_flag = 1;
        aos_kv_set("soft ap flag", &softap_flag, len, 1);
    }
    return 0;
}

int set_softap_flag(unsigned char value)
{
    int ret, len = sizeof(value);
    softap_flag = value;
    ret = aos_kv_set("soft ap flag", &value, len, 1);
    if(ret != 0){
        LOG("kv set failed ret = %d", ret);
    }
}

inline const unsigned char get_softap_flag(void)
{
    return softap_flag;
}
```

#### tools/bk7231udevkitc.sh
```
    if [[ "$2" == httpapp ]] || [[ "$2" == coapapp ]];then
-       COMMON_LIBS="$p/$2.a  $p/board_bk7231u.a  $p/vcall.a  $p/kernel_init.a  $p/auto_component.a  $p/libiot_sdk.a $p/iotx-hal.a  $p/hal_init.a  $p/netmgr.a  $p/framework.a  $p/cjson.a   $p/cli.a   $p/$ARCH.a  $p/newlib_stub.a  $p/rhino.a  $p/digest_algorithm.a  $p/net.a  $p/log.a  $p/activation.a  $p/chip_code.a  $p/imbedtls.a  $p/kv.a  $p/yloop.a  $p/hal.a   $p/alicrypto.a  $p/vfs.a  $p/vfs_device.a   $p/awss_security.a $p/libaiotss.a "
+       COMMON_LIBS="$p/$2.a  $p/mbedtls_wrapper.a  $p/libwebsockets.a  $p/board_bk7231u.a  $p/vcall.a  $p/kernel_init.a  $p/auto_component.a  $p/libiot_sdk.a $p/iotx-hal.a  $p/hal_init.a  $p/netmgr.a  $p/framework.a  $p/cjson.a   $p/cli.a   $p/$ARCH.a  $p/newlib_stub.a  $p/rhino.a  $p/digest_algorithm.a  $p/net.a  $p/log.a  $p/activation.a  $p/chip_code.a  $p/imbedtls.a  $p/kv.a  $p/yloop.a  $p/hal.a   $p/alicrypto.a  $p/vfs.a  $p/vfs_device.a   $p/awss_security.a $p/libaiotss.a "
    else
-       COMMON_LIBS="$p/$2.a  $p/board_bk7231u.a  $p/vcall.a  $p/kernel_init.a  $p/auto_component.a  $p/libiot_sdk.a $p/iotx-hal.a  $p/hal_init.a  $p/netmgr.a  $p/framework.a  $p/cjson.a  $p/ota.a  $p/cli.a  $p/ota_hal.a  $p/$ARCH.a  $p/newlib_stub.a  $p/rhino.a  $p/digest_algorithm.a  $p/net.a  $p/log.a  $p/activation.a  $p/chip_code.a  $p/imbedtls.a  $p/kv.a  $p/yloop.a  $p/hal.a  $p/ota_transport.a  $p/ota_download.a  $p/ota_verify.a  $p/base64.a  $p/alicrypto.a  $p/vfs.a  $p/vfs_device.a   $p/awss_security.a $p/libaiotss.a "
+       COMMON_LIBS="$p/$2.a  $p/mbedtls_wrapper.a  $p/libwebsockets.a  $p/board_bk7231u.a  $p/vcall.a  $p/kernel_init.a  $p/auto_component.a  $p/libiot_sdk.a $p/iotx-hal.a  $p/hal_init.a  $p/netmgr.a  $p/framework.a  $p/cjson.a  $p/ota.a  $p/cli.a  $p/ota_hal.a  $p/$ARCH.a  $p/newlib_stub.a  $p/rhino.a  $p/digest_algorithm.a  $p/net.a  $p/log.a  $p/activation.a  $p/chip_code.a  $p/imbedtls.a  $p/kv.a  $p/yloop.a  $p/hal.a  $p/ota_transport.a  $p/ota_download.a  $p/ota_verify.a  $p/base64.a  $p/alicrypto.a  $p/vfs.a  $p/vfs_device.a   $p/awss_security.a $p/libaiotss.a "
    fi
```
