#!/bin/sh

./pre-website.sh
cd website
USE_SSH=true npm run deploy
cd ..
./post-website.sh
