From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 14:19:42 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20100329141942.21547.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 14:19:42

Modified files:
	test           : Makefile.in 

Log message:
	Split long line in Makefile and keep $abs_top_buildir as shell variable
	within init.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/test/Makefile.in	2010/03/29 14:18:01	1.29
+++ LVM2/test/Makefile.in	2010/03/29 14:19:42	1.30
@@ -60,8 +60,10 @@
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
 	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
-	echo 'PATH=$(abs_top_builddir)/test/bin:$$PATH' >> $@-t
-	echo 'export LD_LIBRARY_PATH="$(abs_top_builddir)/libdm:$(abs_top_builddir)/liblvm:$(abs_top_builddir)/daemons/dmeventd"' >> $@-t
+	echo 'PATH=$$abs_top_builddir/test/bin:$$PATH' >> $@-t
+	LDLPATH="\$$abs_top_builddir/libdm"; \
+	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd"; \
+	echo "export LD_LIBRARY_PATH=\"$$LDLPATH\"" >> $@-t
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t


