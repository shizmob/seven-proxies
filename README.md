# seven proxies

hacky PoC for generating Windows proxy DLLs.

## requirements

* sh, POSIX base utils
* make
* mingw-w64 (or another GNU-based Windows toolchain)

## usage

* set cross-compilation environment: `export CROSS_COMPILE=i686-w64-mingw32-` (or `x86_64-w64-mingw32-`)
* get original DLL: `cp /somewhere/mylib.dll mylib-orig.dll`
* create template: `make mylib.c`
* edit template to perform your injection magic
* create proxy DLL: `make mylib.dll`
* move into place: `cp mylib.dll mylib-orig.dll /destination`

## license

0bsd
