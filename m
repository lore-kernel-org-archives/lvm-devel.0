From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Jul 2010 10:57:04 -0000
Subject: LVM2 ./WHATS_NEW_DM man/Makefile.in
Message-ID: <20100701105704.15183.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-01 10:57:03

Modified files:
	.              : WHATS_NEW_DM 
	man            : Makefile.in 

Log message:
	Move dmeventd man page from install_lvm2 to install_device-mapper. (1.02.50)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.385&r2=1.386
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/WHATS_NEW_DM	2010/06/30 14:50:32	1.385
+++ LVM2/WHATS_NEW_DM	2010/07/01 10:57:03	1.386
@@ -1,5 +1,6 @@
 Version 1.02.52 -
 ================================
+  Move dmeventd man page from install_lvm2 to install_device-mapper. (1.02.50)
 
 Version 1.02.51 - 30th June 2010
 ================================
--- LVM2/man/Makefile.in	2010/06/18 10:19:30	1.39
+++ LVM2/man/Makefile.in	2010/07/01 10:57:03	1.40
@@ -36,7 +36,7 @@
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(DMEVENTDMAN)
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN)
 
 ifneq ("@CLVMD@", "none")
   MAN8CLUSTER=clvmd.8
@@ -47,7 +47,7 @@
   MAN8CLUSTER+=cmirrord.8
 endif
 
-MAN8DM=dmsetup.8
+MAN8DM=dmsetup.8 $(DMEVENTDMAN)
 MAN5DIR=$(mandir)/man5
 MAN8DIR=$(mandir)/man8
 


