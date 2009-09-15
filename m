From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Sep 2009 19:59:05 -0000
Subject: LVM2 ./WHATS_NEW test/Makefile.in
Message-ID: <20090915195905.23274.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-15 19:59:05

Modified files:
	.              : WHATS_NEW 
	test           : Makefile.in 

Log message:
	Fix lvm2app test to run under test/api subdirectory only when configured.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1266&r2=1.1267
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2009/09/15 18:35:13	1.1266
+++ LVM2/WHATS_NEW	2009/09/15 19:59:04	1.1267
@@ -1,5 +1,6 @@
 Version 2.02.53 - 
 =====================================
+  Fix lvm2app test to run under test/api subdirectory only when configured.
   Add vg_is_resizeable() and cleanup reference to VG_RESIZEABLE.
 
 Version 2.02.52 - 15th September 2009
--- LVM2/test/Makefile.in	2009/09/04 12:54:23	1.18
+++ LVM2/test/Makefile.in	2009/09/15 19:59:05	1.19
@@ -53,7 +53,10 @@
 T = $(wildcard t-*.sh)
 
 ifeq ("@APPLIB@", "yes")
-  T += lvm2app.sh
+T += lvm2app.sh
+all: api/vgtest
+api/vgtest:
+	$(MAKE) -C api vgtest
 endif
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status


