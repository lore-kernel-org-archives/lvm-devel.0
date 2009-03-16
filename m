From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Mar 2009 18:28:05 -0000
Subject: LVM2 ./Makefile.in scripts/Makefile.in test/Ma ...
Message-ID: <20090316182805.9618.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-16 18:28:05

Modified files:
	.              : Makefile.in 
	scripts        : Makefile.in 
	test           : Makefile.in 

Log message:
	Fix some distclean rules.
	
	By gnu coding stds, 'distclean' should remove all files generated
	by ./configure in addition to what 'clean' does.
	
	Author: Takahiro Yasui <tyasui@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/Makefile.in	2009/03/06 16:19:52	1.31
+++ LVM2/Makefile.in	2009/03/16 18:28:04	1.32
@@ -27,14 +27,16 @@
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS += daemons/clvmd \
 	     daemons/dmeventd/plugins \
+	     daemons/dmeventd \
 	     lib/format1 \
 	     lib/format_pool \
 	     lib/locking \
 	     lib/mirror \
 	     lib/snapshot \
+	     test/api \
 	     test \
 	     po
-  DISTCLEAN_TARGETS += lib/misc/configure.h
+  DISTCLEAN_TARGETS += lib/misc/configure.h lib/misc/lvm-version.h
   DISTCLEAN_DIRS += lcov_reports*
 endif
 
--- LVM2/scripts/Makefile.in	2008/11/01 02:19:18	1.4
+++ LVM2/scripts/Makefile.in	2009/03/16 18:28:05	1.5
@@ -24,3 +24,6 @@
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) fsadm.sh \
 		$(sbindir)/fsadm
 endif
+
+distclean:
+	$(RM) Makefile clvmd_init_red_hat
--- LVM2/test/Makefile.in	2009/02/12 19:54:45	1.16
+++ LVM2/test/Makefile.in	2009/03/16 18:28:05	1.17
@@ -81,6 +81,7 @@
 	rm -rf init.sh lvm-wrapper bin .bin-dir-stamp
 
 distclean: clean
+	rm -f Makefile
 
 .PHONY: $(T) clean distclean
 .NOTPARALLEL:


