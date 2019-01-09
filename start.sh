#!/usr/bin/env sh
docker run --rm -it -v $(pwd):/src -p 9999:1313 klakegg/hugo:0.53 server