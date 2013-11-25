From: Oliver Rath <rath@mglug.de>
Date: Mon, 25 Nov 2013 17:59:25 +0100
Subject: SOLVED [was libcunit not found but installed ]
In-Reply-To: <52937B2B.7040205@redhat.com>
References: <52935E70.6060705@mglug.de>	<52936896.8040905@redhat.com>	<52936FB7.9050803@mglug.de>	<529377F8.9090905@redhat.com>	<529378E3.10603@redhat.com>	<529379EC.6070903@mglug.de>
	<52937B2B.7040205@redhat.com>
Message-ID: <529381ED.2030407@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek!

Am 25.11.2013 17:30, schrieb Zdenek Kabelac:
> prefix=/usr
> exec_prefix=/usr
> libdir=/usr/lib64
> includedir=/usr/include
>
> Name: CUnit
> Description: C Unit Testing Framework
> Version: 2.1
> Libs: -L${libdir} -lcunit
> Cflags: -I${includedir} 

Putting this file to/usr /lib/pkgconfig/cunit.pc solved my problem for
now. Thanks a lot! Furthermore unfortunatly i have noch idea how to
enhance configure.in for appropriate work in ubuntu, Ive never done this
before.

Regards,
Oliver


