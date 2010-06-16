From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 16 Jun 2010 18:55:59 -0400
Subject: [PATCH][RFC] Fix lvconvert repair at mirror leg and log failure (v2)
Message-ID: <4C19567F.8070409@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Fixed some issues in the previous patch.

v2 changes:
  - rename _lv_update_log() to _lv_update_mirrored_log()
  - restore _reload_lv() in _lv_update_mirrored_log()
  - pass an updated new_log_count value to _lv_update_mirrored_log()

Appreciate your review and comments.

Thanks,
Taka


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 tools/lvconvert.c |   33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

Index: LVM2-2.02.67/tools/lvconvert.c
===================================================================
--- LVM2-2.02.67.orig/tools/lvconvert.c
+++ LVM2-2.02.67/tools/lvconvert.c
@@ -689,6 +689,27 @@ static int _get_log_count(struct logical
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
@@ -1218,15 +1239,23 @@ static int _lvconvert_mirrors_repair(str
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
 


