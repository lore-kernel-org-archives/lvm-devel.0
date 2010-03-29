From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 14:06:06 -0000
Subject: LVM2 Makefile.in
Message-ID: <20100329140606.16583.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 14:06:06

Modified files:
	.              : Makefile.in 

Log message:
	Avoid hard sed replacement - i.e. quick test change in make.tmpl
	could avoid recofiguration steps in same debug cases.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/Makefile.in	2009/10/02 19:10:31	1.42
+++ LVM2/Makefile.in	2010/03/29 14:06:06	1.43
@@ -88,7 +88,7 @@
 check: all
 	$(MAKE) -C test all
 
-ifneq ("@LCOV@", "")
+ifneq ("$(LCOV)", "")
 .PHONY: lcov-reset lcov lcov-dated
 
 ifeq ($(MAKECMDGOALS),lcov-dated)
@@ -116,7 +116,7 @@
 		-a $(LCOV_REPORTS_DIR)/libdm.info \
 		-a $(LCOV_REPORTS_DIR)/tools.info \
 		-o $(LCOV_REPORTS_DIR)/lvm.info
-ifneq ("@GENHTML@", "")
+ifneq ("$(GENHTML)", "")
 	$(GENHTML) -o $(LCOV_REPORTS_DIR) -p $(top_srcdir) $(LCOV_REPORTS_DIR)/lvm.info
 endif
 


