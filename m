From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Nov 2009 12:01:39 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20091119120139.24724.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-19 12:01:39

Modified files:
	test           : Makefile.in 

Log message:
	Fix the dmeventd LD_LIBRARY_PATH in the testsuite.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/test/Makefile.in	2009/11/02 15:16:21	1.20
+++ LVM2/test/Makefile.in	2009/11/19 12:01:39	1.21
@@ -40,7 +40,7 @@
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
 	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
 	echo 'PATH=$(abs_top_builddir)/test/bin:$$PATH' >> $@-t
-	echo 'export LD_LIBRARY_PATH="$(abs_top_builddir)/libdm:$(abs_top_builddir)/liblvm:$(abs_top_builddir)/dmeventd"' >> $@-t
+	echo 'export LD_LIBRARY_PATH="$(abs_top_builddir)/libdm:$(abs_top_builddir)/liblvm:$(abs_top_builddir)/daemons/dmeventd"' >> $@-t
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t


