# anonvpn 使用详解

    java -jar i2pinstall_0.9.44.jar -console
    cd ~/i2p
    ./i2prouter start
    ./i2prouter status

    go get -u -d -tags cli github.com/RTradeLtd/libanonvpn/cmd/anonvpn
    cd ~/go/src/github.com/RTradeLtd/libanonvpn/cmd/anonvpn
    make dependencies
    make
    cp etc/anonvpn/i2cp.conf ~/.i2cp.conf
    ./cmd/anonvpn/anonvpn-gui