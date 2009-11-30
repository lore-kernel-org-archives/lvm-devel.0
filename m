From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2009 16:58:53 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20091130165853.4882.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-30 16:58:53

Modified files:
	test           : Makefile.in 

Log message:
	The sourcedir instances of the test scripts are not PHONY.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/test/Makefile.in	2009/11/30 16:56:42	1.23
+++ LVM2/test/Makefile.in	2009/11/30 16:58:53	1.24
@@ -65,9 +65,6 @@
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
 
-#$(T): init.sh
-#	./bin/harness $@
-
 .bin-dir-stamp: lvm-wrapper
 	rm -rf bin
 	mkdir bin
@@ -93,5 +90,5 @@
 distclean: clean
 	rm -f Makefile
 
-.PHONY: $(T) clean distclean
+.PHONY: clean distclean
 .NOTPARALLEL:


