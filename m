From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Apr 2009 17:00:32 -0000
Subject: LVM2 ./WHATS_NEW test/t-partial-activate.sh to ...
Message-ID: <20090422170032.16152.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-22 17:00:31

Modified files:
	.              : WHATS_NEW 
	test           : t-partial-activate.sh 
	tools          : vgreduce.c 

Log message:
	Fix vgreduce --removemissing failure exit code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1093&r2=1.1094
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-partial-activate.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89

--- LVM2/WHATS_NEW	2009/04/22 09:39:45	1.1093
+++ LVM2/WHATS_NEW	2009/04/22 17:00:28	1.1094
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix vgreduce --removemissing failure exit code.
   Fix remote metadata backup for clvmd.
   Alloc PV internal structure from VG mempool if possible.
   Fix metadata backup to run after vg_commit always.
--- LVM2/test/t-partial-activate.sh	2008/09/29 16:04:57	1.1
+++ LVM2/test/t-partial-activate.sh	2009/04/22 17:00:30	1.2
@@ -6,7 +6,6 @@
 lvchange -a n $vg/mirror
 disable_dev $dev1
 
-# FIXME should this return an error code due to that big fat WARNING?
-vgreduce --removemissing $vg
+not vgreduce --removemissing $vg
 not lvchange -v -a y $vg/mirror
 lvchange -v --partial -a y $vg/mirror
--- LVM2/tools/vgreduce.c	2009/04/10 10:01:39	1.88
+++ LVM2/tools/vgreduce.c	2009/04/22 17:00:31	1.89
@@ -556,11 +556,13 @@
 		}
 		backup(vg);
 
-		if (fixed)
+		if (fixed) {
 			log_print("Wrote out consistent volume group %s",
 				  vg_name);
+			ret = ECMD_PROCESSED;
+		} else
+			ret = ECMD_FAILED;
 
-		ret = ECMD_PROCESSED;
 	} else {
 		if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG))
 			goto out;


