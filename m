From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2009 16:56:42 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20091130165642.3246.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-30 16:56:42

Modified files:
	test           : Makefile.in 

Log message:
	Don't fail in the builddir == srcdir case, though. (testsuite)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/test/Makefile.in	2009/11/30 14:59:26	1.22
+++ LVM2/test/Makefile.in	2009/11/30 16:56:42	1.23
@@ -58,9 +58,9 @@
 	echo 'export PATH' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
-	test "$(srcdir)" != "." && cp $(srcdir)/test-utils.sh \
-	                              $(srcdir)/test-lib.sh \
-	                              $(T) .
+	if test "$(srcdir)" != "."; then cp $(srcdir)/test-utils.sh \
+	                                    $(srcdir)/test-lib.sh \
+	                                    $(T) .; fi
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@


