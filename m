From: meyering@sourceware.org <meyering@sourceware.org>
Date: 18 Sep 2007 14:29:07 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20070918142907.30429.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-18 14:29:07

Modified files:
	test           : Makefile.in 

Log message:
	test/Makefile.in (lvm-wrapper): Use $(DMDIR)/lib/, not $(DMDIR)/lib/ioctl/.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/Makefile.in	2007/09/18 14:02:22	1.4
+++ LVM2/test/Makefile.in	2007/09/18 14:29:06	1.5
@@ -65,7 +65,7 @@
 	rm -f $@-t $@
 	echo '#!/bin/sh'                                          >  $@-t
 	test -n "@DMDIR@" \
-	  && echo 'export LD_LIBRARY_PATH="@DMDIR@/lib/ioctl"'    >> $@-t
+	  && echo 'export LD_LIBRARY_PATH="@DMDIR@/lib"'          >> $@-t
 	echo 'cmd=$$(echo ./$$0|sed "s,.*/,,")'                   >> $@-t
 	echo 'test "$$cmd" = lvm &&'                              >> $@-t
 	echo 'exec "$(abs_top_builddir)/tools/lvm" "$$@"'         >> $@-t


