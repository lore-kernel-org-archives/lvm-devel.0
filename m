From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 4 Nov 2008 14:37:11 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20081104143711.3589.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-04 14:37:11

Modified files:
	test           : Makefile.in 

Log message:
	Use $(abs_top_builddir) instead of @DMDIR@ and update paths appropriately.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/test/Makefile.in	2008/09/29 16:07:02	1.12
+++ LVM2/test/Makefile.in	2008/11/04 14:37:10	1.13
@@ -57,14 +57,13 @@
 	for i in lvm $$(cat $(top_srcdir)/tools/.commands); do \
 	  ln -s ../lvm-wrapper bin/$$i; \
 	done
-	test -n "@DMDIR@" && ln -s "@DMDIR@/dmsetup/dmsetup" bin/dmsetup
+	ln -s "$(abs_top_builddir)/tools/dmsetup" bin/dmsetup
 	touch $@
 
 lvm-wrapper: Makefile
 	rm -f $@-t $@
 	echo '#!/bin/sh'                                          >  $@-t
-	test -n "@DMDIR@" \
-	  && echo 'export LD_LIBRARY_PATH="@DMDIR@/lib:@DMDIR@/dmeventd"' >> $@-t
+	echo 'export LD_LIBRARY_PATH="$(abs_top_builddir)/libdm:$(abs_top_builddir)/dmeventd"' >> $@-t
 	echo 'cmd=$$(echo ./$$0|sed "s,.*/,,")'                   >> $@-t
 	echo 'test "$$cmd" = lvm &&'                              >> $@-t
 	echo 'exec "$(abs_top_builddir)/tools/lvm" "$$@"'         >> $@-t


