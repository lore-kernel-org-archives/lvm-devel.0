From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 23 Jun 2010 20:32:31 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100623203231.28578.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-06-23 20:32:29

Modified files:
	tools          : lvconvert.c 

Log message:
	Committing Taka's patch...  He found a problem during
	the failure of a device that contained both a image of
	a mirror and an image of the mirrored log.  The order
	of the handling of those faults was important (and
	wrong), this patch corrects that.
	
	Patch-From: Takahiro Yasui <tyasui@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135

--- LVM2/tools/lvconvert.c	2010/05/24 15:32:21	1.134
+++ LVM2/tools/lvconvert.c	2010/06/23 20:32:29	1.135
@@ -689,6 +689,27 @@
 	return lv_mirror_count(log_lv);
 }
 
+static int _lv_update_mirrored_log(struct logical_volume *lv,
+				   struct dm_list *operable_pvs,
+				   int log_count)
+{
+	int old_log_count;
+	struct logical_volume *log_lv;
+
+	log_lv = first_seg(_original_lv(lv))->log_lv;
+	if (!log_lv || !(log_lv->status & MIRRORED))
+		return 1;
+
+	old_log_count = _get_log_count(lv);
+	if (old_log_count == log_count)
+		return 1;
+
+	/* Reducing redundancy of the log */
+	return remove_mirror_images(log_lv, log_count,
+				    is_mirror_image_removable,
+				    operable_pvs, 0U);
+}
+
 static int _lv_update_log_type(struct cmd_context *cmd,
 			       struct lvconvert_params *lp,
 			       struct logical_volume *lv,
@@ -1218,15 +1239,23 @@
 	 * We must adjust the log first, or the entire mirror
 	 * will get stuck during a suspend.
 	 */
-	if (!_lv_update_log_type(cmd, lp, lv, failed_pvs, new_log_count))
+	if (!_lv_update_mirrored_log(lv, failed_pvs, new_log_count))
 		return 0;
 
+	if (lp->mirrors == 1)
+		new_log_count = 0;
+
 	if (failed_mirrors) {
-		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, new_log_count,
+		if (!lv_remove_mirrors(cmd, lv, failed_mirrors,
+				       new_log_count ? 0U : 1U,
 				       _is_partial_lv, NULL, 0))
 			return 0;
 	}
 
+	if (!_lv_update_log_type(cmd, lp, lv, failed_pvs,
+				 new_log_count))
+		return 0;
+
 	if (!_reload_lv(cmd, lv))
 		return 0;
 


