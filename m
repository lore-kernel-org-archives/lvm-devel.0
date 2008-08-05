From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Aug 2008 12:32:08 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20080805123208.11982.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-05 12:32:08

Modified files:
	test           : Makefile.in 

Log message:
	put dmeventd into the LD_LIBRARY_PATH for lvm-wrapper

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/Makefile.in	2008/06/27 19:24:17	1.9
+++ LVM2/test/Makefile.in	2008/08/05 12:32:08	1.10
@@ -63,7 +63,7 @@
 	rm -f $@-t $@
 	echo '#!/bin/sh'                                          >  $@-t
 	test -n "@DMDIR@" \
-	  && echo 'export LD_LIBRARY_PATH="@DMDIR@/lib"'          >> $@-t
+	  && echo 'export LD_LIBRARY_PATH="@DMDIR@/lib:@DMDIR@/dmeventd"' >> $@-t
 	echo 'cmd=$$(echo ./$$0|sed "s,.*/,,")'                   >> $@-t
 	echo 'test "$$cmd" = lvm &&'                              >> $@-t
 	echo 'exec "$(abs_top_builddir)/tools/lvm" "$$@"'         >> $@-t


