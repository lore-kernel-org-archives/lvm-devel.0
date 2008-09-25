From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 25 Sep 2008 15:59:11 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20080925155911.6409.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-09-25 15:59:11

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Fix handling of PVs which reappeared with old metadata version.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.966&r2=1.967
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.192&r2=1.193

--- LVM2/WHATS_NEW	2008/09/25 15:52:28	1.966
+++ LVM2/WHATS_NEW	2008/09/25 15:59:10	1.967
@@ -1,5 +1,6 @@
 Version 2.02.41 -
 =====================================
+  Fix handling of PVs which reappeared with old metadata version.
   Fix mirror DSO to call vgreduce with proper parameters.
   Fix validation of --minor and --major in lvcreate to require -My always.
   Fix release: clvmd build, vgreduce consolidate & tests, /dev/ioerror warning.
--- LVM2/lib/metadata/metadata.c	2008/09/25 15:57:02	1.192
+++ LVM2/lib/metadata/metadata.c	2008/09/25 15:59:10	1.193
@@ -1871,11 +1871,10 @@
 			/* FIXME Also ensure contents same - checksums same? */
 			if (correct_vg->seqno != vg->seqno) {
 				inconsistent = 1;
-				if (vg->seqno > correct_vg->seqno) {
-					if (!_update_pv_list(&all_pvs, vg))
-						return_NULL;
+				if (!_update_pv_list(&all_pvs, vg))
+					return_NULL;
+				if (vg->seqno > correct_vg->seqno)
 					correct_vg = vg;
-				}
 			}
 		}
 
@@ -2270,6 +2269,7 @@
 
 	pv->vg_name = cmd->fmt->orphan_vg_name;
 	pv->status = ALLOCATABLE_PV;
+	pv->pe_alloc_count = 0;
 
 	if (!dev_get_size(pv->dev, &pv->size)) {
 		log_error("%s: Couldn't get size.", pv_dev_name(pv));


