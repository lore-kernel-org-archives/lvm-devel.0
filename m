From: taka@sourceware.org <taka@sourceware.org>
Date: 30 Jul 2010 17:50:17 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20100730175017.23464.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	taka at sourceware.org	2010-07-30 17:50:16

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Fix wrong number of mirror log at allocate policy
	
	With mirror_log_fault_policy of 'remove' and mirror_image_fault_policy
	of 'allocate', the log type of the mirror volume is converted from
	'disk' or 'mirrored' to 'core' when all mirror legs but one in a mirror
	volume broke.
	
	Keep new_log_count as a number of valid log devices by using log_count
	variable for a temporary usage in the first phase of error recovery
	in _lvconvert_mirrors_repair().
	
	Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1677&r2=1.1678
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141

--- LVM2/WHATS_NEW	2010/07/28 21:58:08	1.1677
+++ LVM2/WHATS_NEW	2010/07/30 17:50:15	1.1678
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix wrong number of mirror log at allocate policy
 
 Version 2.02.72 - 28th July 2010  [CVE-2010-2526]
 =================================================
--- LVM2/tools/lvconvert.c	2010/07/13 22:04:36	1.140
+++ LVM2/tools/lvconvert.c	2010/07/30 17:50:16	1.141
@@ -1237,25 +1237,27 @@
 	if (!(lp->failed_pvs = _failed_pv_list(lv->vg)))
 		return_0;
 
+	log_count = new_log_count;
+
 	/*
 	 * We must adjust the log first, or the entire mirror
 	 * will get stuck during a suspend.
 	 */
-	if (!_lv_update_mirrored_log(lv, lp->failed_pvs, new_log_count))
+	if (!_lv_update_mirrored_log(lv, lp->failed_pvs, log_count))
 		return 0;
 
 	if (lp->mirrors == 1)
-		new_log_count = 0;
+		log_count = 0;
 
 	if (failed_mirrors) {
 		if (!lv_remove_mirrors(cmd, lv, failed_mirrors,
-				       new_log_count ? 0U : 1U,
+				       log_count ? 0U : 1U,
 				       _is_partial_lv, NULL, 0))
 			return 0;
 	}
 
 	if (!_lv_update_log_type(cmd, lp, lv, lp->failed_pvs,
-				 new_log_count))
+				 log_count))
 		return 0;
 
 	if (!_reload_lv(cmd, lv))


