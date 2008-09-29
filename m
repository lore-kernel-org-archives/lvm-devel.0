From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Sep 2008 16:07:02 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20080929160702.22397.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-29 16:07:02

Modified files:
	test           : Makefile.in 

Log message:
	Update test/Makefile.in to use the new harness for calling tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/test/Makefile.in	2008/08/28 10:07:33	1.11
+++ LVM2/test/Makefile.in	2008/09/29 16:07:02	1.12
@@ -26,6 +26,8 @@
 abs_top_srcdir = @abs_top_srcdir@
 
 all: init.sh
+	sh harness.sh
+
 init.sh: Makefile.in .bin-dir-stamp
 	rm -f $@-t $@
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
@@ -47,8 +49,7 @@
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
 
 $(T): init.sh
-	@echo "*** $@ ***"; '$(SHELL_PATH_SQ)' \
-	  $(TESTS_ENVIRONMENT) $@ $(LVM_TEST_OPTS)
+	sh harness.sh $@
 
 .bin-dir-stamp: lvm-wrapper
 	rm -rf bin
@@ -76,6 +77,5 @@
 
 distclean: clean
 
-all: $(T)
 .PHONY: $(T) clean distclean
 .NOTPARALLEL:


