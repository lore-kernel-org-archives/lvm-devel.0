From: gaobotian <gaobotian@126.com>
Date: Sat, 27 Sep 2008 14:22:45 +0800 (CST)
Subject: lvm2_exit
Message-ID: <23037927.208171222496565666.JavaMail.coremail@bj126app56.126.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 
<<<<<<<$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

The program is following;

<<<<<<$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

 

#include "lvm2cmd.h"

void test_log_fn(int level, const char *file, int line, const char *format)

{

    if (level != 4)

        return;

    printf("%s\n", format);

    return;

}

int main(int argc, char **argv)

{

    void *handle;

    void *handle2;

    int r;

 

    lvm2_log_fn(test_log_fn);

 

    handle = lvm2_init();

 

    lvm2_log_level(handle, 1);

    r = lvm2_run(handle, "vgs");

    lvm2_exit(handle);

 

    lvm2_log_fn(test_log_fn);

    handle2 = lvm2_init();

    lvm2_log_level(handle2, 1);

    r = lvm2_run(handle2, "vgs");

    lvm2_exit(handle2);

 

 

    return r;

}

 

 

<<<<<<$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

The Makefile is:

<<<<<<$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

 

PURECOV = purify

CC      = $(PURECOV)  gcc

INCLUDES= -I/usr/include/

LIBS =  -L/usr/lib/

LFLAGS = -g -llvm2cmd  -ldevmapper -ldevmapper-event

 

 

all : lvm2test

 

 

lvm2test : lvm2test.o

    $(CC) $^ -o $@    $(LIBS) $(LFLAGS)  $(INCLUDES)

 

lvm2test.o : lvm2test.c

    $(CC) -c $< -o $@   $(INCLUDES)

 

 

clean :

rm -rf *.o lvm2test

 

<<<<<<$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

But there is some memory leak, the result is following:

Why? I want to know why and how to program?

<<<<<<$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

 

****  Purify instrumented ./lvm2test (pid 10015 at Sat Sep 27 13:57:52 2008)

  * Purify 7.0 Linux (64-bit) (C) Copyright IBM Corporation. 1992, 2006 All Rights Reserved.  

  * For contact information type: "purify -help"

  * For Purify Viewer output, set the DISPLAY environment variable.

  * Options settings: -purify \

    -purify-home=/opt/Rational/releases/purify.i386_linux2.7.0 \

    -gcc3_path=/usr/bin/gcc \

    -cache-dir=/opt/Rational/releases/purify.i386_linux2.7.0/cache -hw_cap=yes 

  * Command-line: ./lvm2test 

 

****  Purify instrumented ./lvm2test (pid 10015)  ****

UMR: Uninitialized memory read:

  * This is occurring while in thread 10015:

        *unknown func* [pc=0x36cac205bb]

        dm_regex_create [libdevmapper.so.1.02]

        *unknown func* [pc=0x2a955880fa]

        *unknown func* [pc=0x2a9556d6ab]

        *unknown func* [pc=0x2a9556f277]

        *unknown func* [pc=0x2a95613109]

  * Reading 4 bytes from 0x5a6078 in the heap.

  * Address 0x5a6078 is 1344 bytes into a malloc'd block at 0x5a5b38 of 16384 bytes.

  * This block was allocated from thread -1782043904:

        malloc         [rtlib.o]

        *unknown func* [pc=0x36cac1b0da]

        dm_pool_alloc_aligned [libdevmapper.so.1.02]

        dm_regex_create [libdevmapper.so.1.02]

        *unknown func* [pc=0x2a955880fa]

        *unknown func* [pc=0x2a9556d6ab]

 

****  Purify instrumented ./lvm2test (pid 10015)  ****

UMR: Uninitialized memory read:

  * This is occurring while in thread 10015:

        *unknown func* [pc=0x36cac205bb]

        dm_regex_create [libdevmapper.so.1.02]

        *unknown func* [pc=0x2a955880fa]

        *unknown func* [pc=0x2a9556d6ab]

        *unknown func* [pc=0x2a9556f277]

        *unknown func* [pc=0x2a95613109]

  * Reading 4 bytes from 0x5a60c8 in the heap.

  * Address 0x5a60c8 is 1424 bytes into a malloc'd block at 0x5a5b38 of 16384 bytes.

  * This block was allocated from thread -1782043904:

        malloc         [rtlib.o]

        *unknown func* [pc=0x36cac1b0da]

        dm_pool_alloc_aligned [libdevmapper.so.1.02]

        dm_regex_create [libdevmapper.so.1.02]

        *unknown func* [pc=0x2a955880fa]

        *unknown func* [pc=0x2a9556d6ab]

VG       #PV #LV #SN Attr   VSize   VFree  

mirrorvg   1   0   0 wz--n- 792.00M792.00M

myvg       2  28   0 wz--n-   2.07G   1.89G

 

****  Purify instrumented ./lvm2test (pid 10015)  ****

FMW: Free memory write:

  * This is occurring while in thread 10015:

        *unknown func* [pc=0x2a956096e8]

        *unknown func* [pc=0x2a95609a02]

        *unknown func* [pc=0x2a95640a30]

        main           [lvm2test.o]

        __libc_start_main [libc.so.6]

        _start         [crt1.o]

  * Writing 8 bytes to 0x58b7b8 in the heap.

  * Address 0x58b7b8 is 2304 bytes into a freed  block at 0x58aeb8 of 3072 bytes.

  * This block was allocated from thread -1782043904:

        malloc         [rtlib.o]

        realloc        [rtlib.o]

        *unknown func* [pc=0x2a95609094]

        *unknown func* [pc=0x2a95609803]

        *unknown func* [pc=0x2a9560de99]

        *unknown func* [pc=0x2a95640a30]

  * There have been 484 frees since this block was freed thread 10015.

 

****  Purify instrumented ./lvm2test (pid 10015)  ****

FMW: Free memory write:

  * This is occurring while in thread 10015:

        *unknown func* [pc=0x2a956096ff]

        *unknown func* [pc=0x2a95609a02]

        *unknown func* [pc=0x2a95640a30]

        main           [lvm2test.o]

        __libc_start_main [libc.so.6]

        _start         [crt1.o]

  * Writing 8 bytes to 0x58b7c0 in the heap.

  * Address 0x58b7c0 is 2312 bytes into a freed  block at 0x58aeb8 of 3072 bytes.

  * This block was allocated from thread -1782043904:

        malloc         [rtlib.o]

        realloc        [rtlib.o]

        *unknown func* [pc=0x2a95609094]

        *unknown func* [pc=0x2a95609803]

        *unknown func* [pc=0x2a9560de99]

        *unknown func* [pc=0x2a95640a30]

  * There have been 484 frees since this block was freed thread 10015.

 

****  Purify instrumented ./lvm2test (pid 10015)  ****

FMW: Free memory write:

  * This is occurring while in thread 10015:

        *unknown func* [pc=0x2a95609717]

        *unknown func* [pc=0x2a95609a02]

        *unknown func* [pc=0x2a95640a30]

        main           [lvm2test.o]

        __libc_start_main [libc.so.6]

        _start         [crt1.o]

  * Writing 8 bytes to 0x58b7c8 in the heap.

  * Address 0x58b7c8 is 2320 bytes into a freed  block at 0x58aeb8 of 3072 bytes.

  * This block was allocated from thread -1782043904:

        malloc         [rtlib.o]

        realloc        [rtlib.o]

        *unknown func* [pc=0x2a95609094]

        *unknown func* [pc=0x2a95609803]

        *unknown func* [pc=0x2a9560de99]

        *unknown func* [pc=0x2a95640a30]

  * There have been 484 frees since this block was freed thread 10015.

 

****  Purify instrumented ./lvm2test (pid 10015)  ****

FMW: Free memory write:

  * This is occurring while in thread 10015:

        *unknown func* [pc=0x2a9560972f]

        *unknown func* [pc=0x2a95609a02]

        *unknown func* [pc=0x2a95640a30]

        main           [lvm2test.o]

        __libc_start_main [libc.so.6]

        _start         [crt1.o]

  * Writing 8 bytes to 0x58b7d0 in the heap.

  * Address 0x58b7d0 is 2328 bytes into a freed  block@0x58aeb8 of 3072 bytes.

  * This block was allocated from thread -1782043904:

        malloc         [rtlib.o]

        realloc        [rtlib.o]

        *unknown func* [pc=0x2a95609094]

        *unknown func* [pc=0x2a95609803]

        *unknown func* [pc=0x2a9560de99]

        *unknown func* [pc=0x2a95640a30]

  * There have been 484 frees since this block was freed thread 10015.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080927/d0d7f5d1/attachment.htm>
