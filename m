From: Juergen Daubert <jue@jue.li>
Date: Tue, 09 Nov 2010 17:16:24 -0000
Subject: linker error with configure option --enable-static_link
Message-ID: <20101109171601.GA30179@jue.netz>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

got the following linker error while trying to build latest lvm2 from
sources with gcc 4.5.1 and binutils 2.20.1 (works with gcc 4.4.x and 
binutils 2.19.1) if --enable-static_link is configured:

cc -O2 -march=i686 -pipe -O2 -march=i686 -pipe -fPIC -Wall -Wundef
-Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes
-Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn
-Wformat-security -Wredundant-decls -O2 -O2 -march=i686 -pipe -fPIC
-Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes
-Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn
-Wformat-security -Wredundant-decls -O2 -Wl,--export-dynamic -L../libdm
-L../lib -static -L../libdm/ioctl \
      -o dmsetup.static dmsetup.o -ldevmapper   -lm  
/usr/bin/ld: dynamic STT_GNU_IFUNC symbol `strcmp' with pointer
equality in
`/usr/lib/gcc/i686-pc-linux-gnu/4.5.1/../../../libc.a(strcmp.o)'
can not be used when making an executable; recompile with -fPIE
and relink with -pie
collect2: ld returned 1 exit status
make[1]: *** [dmsetup.static] Error 1


Thanks
Juergen

-- 
Juergen Daubert  |  mailto:jue at jue.li  
Korb, Germany    |  http://jue.li/crux


