From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Jan 2008 14:17:58 -0000
Subject: LVM2/man Makefile.in
Message-ID: <20080109141758.24911.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-01-09 14:17:58

Modified files:
	man            : Makefile.in 

Log message:
	install conditionally fsadm.8 manpage

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/man/Makefile.in	2007/09/21 10:16:44	1.21
+++ LVM2/man/Makefile.in	2008/01/09 14:17:58	1.22
@@ -16,6 +16,12 @@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
+ifeq ("@FSADM@", "yes")
+FSADMMAN = fsadm.8
+else
+FSADMMAN =
+endif
+
 MAN5=lvm.conf.5
 MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	lvmchange.8 lvmdiskscan.8 lvmdump.8 \
@@ -24,7 +30,7 @@
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 vgrename.8 \
-	vgs.8 vgscan.8 vgsplit.8
+	vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN)
 MAN8CLUSTER=clvmd.8
 MAN5DIR=${mandir}/man5
 MAN8DIR=${mandir}/man8


