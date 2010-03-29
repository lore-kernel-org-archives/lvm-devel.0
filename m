From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 15:39:26 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20100329153926.5569.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 15:39:25

Modified files:
	test           : Makefile.in 

Log message:
	Oops, avoid returning errors from shell to makefile for builddir == srcdir

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/test/Makefile.in	2010/03/29 14:19:42	1.30
+++ LVM2/test/Makefile.in	2010/03/29 15:39:25	1.31
@@ -70,7 +70,7 @@
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
-	test "$(srcdir)" != . && cp $(SCRIPTS) .
+	if  "$(srcdir)" != . ; then  cp $(SCRIPTS) . ; fi
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@


