#!/bin/sh

./pre-website.sh && cd website && npm run build && cd .. && ./post-website.sh
