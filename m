From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 30 Jun 2010 14:01:44 -0000
Subject: LVM2 ./WHATS_NEW test/t-activate-partial.sh to ...
Message-ID: <20100630140144.22610.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-30 14:01:40

Modified files:
	.              : WHATS_NEW 
	test           : t-activate-partial.sh 
	tools          : vgremove.c 

Log message:
	Fix vgremove to allow removal of VG with missing PVs. (2.02.52)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1640&r2=1.1641
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-partial.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2010/06/30 13:11:12	1.1640
+++ LVM2/WHATS_NEW	2010/06/30 14:01:39	1.1641
@@ -1,5 +1,6 @@
 Version 2.02.69 - 
 ================================
+  Fix vgremove to allow removal of VG with missing PVs. (2.02.52)
   Add --metadataignore to pvcreate and vgextend and define in lvm.conf.
   Add {pv|vg}_mda_used_count which displays a count of mdas w/ignored bit clear.
   Add vg_mda_copies which displays the value of --vgmetadatacopies.
--- LVM2/test/t-activate-partial.sh	2010/06/03 12:45:09	1.2
+++ LVM2/test/t-activate-partial.sh	2010/06/30 14:01:39	1.3
@@ -15,3 +15,6 @@
 # also check that vgchange works
 vgchange -a n --partial $vg
 vgchange -a y --partial $vg
+
+# check vgremove
+vgremove -f $vg
\ No newline at end of file
--- LVM2/tools/vgremove.c	2010/01/08 14:03:55	1.59
+++ LVM2/tools/vgremove.c	2010/06/30 14:01:40	1.60
@@ -49,7 +49,7 @@
 		}
 	}
 
-	if (!vg_remove_check(vg)) {
+	if (!force && !vg_remove_check(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}


