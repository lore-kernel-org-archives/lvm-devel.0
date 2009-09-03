From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 3 Sep 2009 18:19:08 -0000
Subject: LVM2/liblvm Makefile.in
Message-ID: <20090903181908.14985.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-09-03 18:19:08

Modified files:
	liblvm         : Makefile.in 

Log message:
	Do not override the distclean target in liblvm's Makefile, it annoys make and
	the make.tmpl-included distclean should work better anyway.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/liblvm/Makefile.in	2009/09/01 18:11:14	1.14
+++ LVM2/liblvm/Makefile.in	2009/09/03 18:19:07	1.15
@@ -93,4 +93,3 @@
 	$(RM) $(LIB_NAME).pc
 
 distclean: distclean_lib
-	$(RM) -f Makefile


