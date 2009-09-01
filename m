From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 1 Sep 2009 18:11:15 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./make.tmpl.in ...
Message-ID: <20090901181115.17276.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2009-09-01 18:11:15

Modified files:
	.              : Makefile.in WHATS_NEW make.tmpl.in 
	liblvm         : Makefile.in 

Log message:
	Remove unwanted Makefiles and don't purge lvm2.po that's
	under RCS.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1247&r2=1.1248
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/Makefile.in	2009/08/13 16:34:07	1.35
+++ LVM2/Makefile.in	2009/09/01 18:11:14	1.36
@@ -42,6 +42,8 @@
 	     lib/locking \
 	     lib/mirror \
 	     lib/snapshot \
+	     liblvm \
+	     udev \
 	     test/api \
 	     test \
 	     po
--- LVM2/WHATS_NEW	2009/09/01 09:48:01	1.1247
+++ LVM2/WHATS_NEW	2009/09/01 18:11:14	1.1248
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Fix Makefile distclean target.
   Make clvmd check corosync to see what cluster interface it should use.
   Rewrite clvmd configuration code to cope with all combinations of libs.
   Fix global locking in PV reporting commands (2.02.49).
--- LVM2/make.tmpl.in	2009/07/31 11:49:53	1.69
+++ LVM2/make.tmpl.in	2009/09/01 18:11:14	1.70
@@ -250,7 +250,7 @@
 	      $(SOURCES:%.c=%.gcda) $(LDDEPS) \
 	      config.cache config.log config.status \
 	      Makefile make.tmpl core \
-	      lvm-version.h lvm2.po
+	      lvm-version.h
 
 .export.sym: .exported_symbols
 	set -e; (echo "Base {"; echo "	global:"; \
--- LVM2/liblvm/Makefile.in	2009/07/29 19:24:11	1.13
+++ LVM2/liblvm/Makefile.in	2009/09/01 18:11:14	1.14
@@ -93,3 +93,4 @@
 	$(RM) $(LIB_NAME).pc
 
 distclean: distclean_lib
+	$(RM) -f Makefile


