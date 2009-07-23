From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jul 2009 01:41:59 -0000
Subject: LVM2/liblvm liblvm2app.pc.in liblvm2app.pc
Message-ID: <20090723014159.7308.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-23 01:41:55

Added files:
	liblvm         : liblvm2app.pc.in 
Removed files:
	liblvm         : liblvm2app.pc 

Log message:
	check in the correct pkgconfig file

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/liblvm2app.pc.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/liblvm2app.pc.diff?cvsroot=lvm2&r1=1.1&r2=NONE

/cvs/lvm2/LVM2/liblvm/liblvm2app.pc.in,v  -->  standard output
revision 1.1
--- LVM2/liblvm/liblvm2app.pc.in
+++ -	2009-07-23 01:41:56.598853000 +0000
@@ -0,0 +1,11 @@
+prefix=@prefix@
+exec_prefix=@exec_prefix@
+libdir=@libdir@
+includedir=@includedir@
+
+Name: lvm2app
+Description: lvm2 application library
+Version: @LVM_MAJOR at .@LVM_LIBAPI@
+Cflags: -I${includedir} 
+Libs: -L${libdir} -llvm2app
+Libs.private: -ldevmapper


