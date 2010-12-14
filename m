From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Dec 2010 23:23:45 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20101214232345.14750.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-12-14 23:23:45

Modified files:
	test           : Makefile.in 

Log message:
	Fix sed substitution in copying tests to builddir (test/Makefile.in).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/test/Makefile.in	2010/12/14 17:38:42	1.48
+++ LVM2/test/Makefile.in	2010/12/14 23:23:45	1.49
@@ -93,7 +93,7 @@
 	@if test "$(srcdir)" != . ; then \
 	    echo "Copying tests to builddir."; \
 	    cp $(SUPPORT) .; \
-	    for f in $(RUN); do cp $$f `echo $$f | sed -e s,$(srcdir)/,,g`; done; \
+	    for f in $(RUN); do cp $$f `echo $$f | sed -e s,^$(srcdir)/,,`; done; \
 	fi
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status


