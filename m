From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jun 2011 14:39:11 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import.c lib/ ...
Message-ID: <20110617143911.4873.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-06-17 14:39:10

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import.c 
	lib/metadata   : metadata.c 

Log message:
	Code move of vg_mark_partial() up in stack
	
	It's useful to keep the partial flag cached - so just move the call
	for vg_mark_partil_lvs() into import_vg_from_config_tree() so it gets
	evaluated before it goes through the lvmcache.
	
	This patch should not present any functional change.
	
	Note: It is rather temporal solution - proper place is probably inside the
	'read' call back - but needs some more discussion.
	For now using this minor hack.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2021&r2=1.2022
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.458&r2=1.459

--- LVM2/WHATS_NEW	2011/06/17 14:30:58	1.2021
+++ LVM2/WHATS_NEW	2011/06/17 14:39:10	1.2022
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Call vg_mark_partial_lvs() before VG structure is returned from the cache.
   Remove unused internal flag ACTIVATE_EXCL from the code.
   Remove useless test of ACTIVATE_EXCL in lv_add_mirrors() clustered code path.
   Use lv_activate_opts struct instead of MERGING status flag.
--- LVM2/lib/format_text/import.c	2011/01/10 13:13:42	1.53
+++ LVM2/lib/format_text/import.c	2011/06/17 14:39:10	1.54
@@ -136,6 +136,7 @@
 {
 	struct volume_group *vg = NULL;
 	struct text_vg_version_ops **vsn;
+	int vg_missing;
 
 	_init_text_import();
 
@@ -148,6 +149,12 @@
 		 */
 		if (!(vg = (*vsn)->read_vg(fid, cft, 1)))
 			stack;
+		else if ((vg_missing = vg_missing_pv_count(vg))) {
+			log_verbose("There are %d physical volumes missing.",
+				    vg_missing);
+			vg_mark_partial_lvs(vg, 1);
+			/* FIXME: move this code inside read_vg() */
+		}
 		break;
 	}
 
--- LVM2/lib/metadata/metadata.c	2011/06/15 17:45:03	1.458
+++ LVM2/lib/metadata/metadata.c	2011/06/17 14:39:10	1.459
@@ -2868,11 +2868,6 @@
 		else	/* Inconsistent but we can't repair it */
 			correct_vg->status &= ~INCONSISTENT_VG;
 
-		if (vg_missing_pv_count(correct_vg)) {
-			log_verbose("There are %d physical volumes missing.",
-				    vg_missing_pv_count(correct_vg));
-			vg_mark_partial_lvs(correct_vg, 1);
-		}
 		return correct_vg;
 	} else {
 		free_vg(correct_vg);


