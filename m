From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 16 Jun 2010 15:52:51 -0400
Subject: [PATCH][RFC] Fix lvconvert repair at mirror leg and log failure
Message-ID: <4C192B93.7070403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I found a case that lvconvert command can't repair failed lvm
mirror volume. When a mirror leg and a mirror log failed at the
same time, lvconvert --repair can't handle the error.

Before mirrored log function was introduced, the sequence of
repair was

  1. Fix mirror legs ... lv_remove_mirrors()
  2. Fix mirror log  ... _lv_update_log_type()

and after mirrored log function was introduced, the sequence was
changed as follows because a recovery of mirror log should be done
before a recovery of mirror leg is done.

  1. Fix mirror log  ... _lv_update_log_type()
  2. Fix mirror legs ... lv_remove_mirrors()

It seems to introduced this issue. In _lv_update_log_type() function
handles not only mirror log but also mirror leg and it does not seem
to work properly.

One of the solutions to fix this issue is to change the sequence as
the one before mirror log function was introduced and to add
a function to handle a failure of mirrored log before mirror leg is
recovered.

  1. Fix mirrored log ... _lv_update_log() <NEW function>
     _lv_update_log() handles errors inside mirrored log and doesn't
     change an original lv.
  2. Fix mirror legs  ... lv_remove_mirrors()
  3. Fix mirror log   ... _lv_update_log_type()

I created a RFC patch and it worked well for my test cases.

Appreciate your review and comments.

Thanks,
Taka


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 tools/lvconvert.c |   32 +++++++++++++++++++++++++++-----
 1 file changed, 27 insertions(+), 5 deletions(-)

Index: LVM2-2.02.67/tools/lvconvert.c
===================================================================
--- LVM2-2.02.67.orig/tools/lvconvert.c
+++ LVM2-2.02.67/tools/lvconvert.c
@@ -689,6 +689,27 @@ static int _get_log_count(struct logical
 	return lv_mirror_count(log_lv);
 }
 
+static int _lv_update_log(struct cmd_context *cmd,
+			  struct lvconvert_params *lp,
+			  struct logical_volume *lv,
+			  struct dm_list *operable_pvs,
+			  int log_count)
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
+	return remove_mirror_images(log_lv, log_count, is_mirror_image_removable, operable_pvs, 0U);
+}
+
 static int _lv_update_log_type(struct cmd_context *cmd,
 			       struct lvconvert_params *lp,
 			       struct logical_volume *lv,
@@ -717,6 +738,8 @@ static int _lv_update_log_type(struct cm
 		return 1;
 	}
 
+	log_lv = first_seg(original_lv)->log_lv;
+
 	/* Remove an existing log completely */
 	if (!log_count) {
 		if (!remove_mirror_log(cmd, original_lv, operable_pvs))
@@ -724,8 +747,6 @@ static int _lv_update_log_type(struct cm
 		return 1;
 	}
 
-	log_lv = first_seg(original_lv)->log_lv;
-
 	/* Adding redundancy to the log */
 	if (old_log_count < log_count) {
 		log_error("Adding log redundancy not supported yet.");
@@ -1218,16 +1239,17 @@ static int _lvconvert_mirrors_repair(str
 	 * We must adjust the log first, or the entire mirror
 	 * will get stuck during a suspend.
 	 */
-	if (!_lv_update_log_type(cmd, lp, lv, failed_pvs, new_log_count))
+	if (!_lv_update_log(cmd, lp, lv, failed_pvs, new_log_count))
 		return 0;
 
 	if (failed_mirrors) {
-		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, new_log_count,
+		if (!lv_remove_mirrors(cmd, lv, failed_mirrors,
+				       new_log_count ? 0 : 1,
 				       _is_partial_lv, NULL, 0))
 			return 0;
 	}
 
-	if (!_reload_lv(cmd, lv))
+	if (!_lv_update_log_type(cmd, lp, lv, failed_pvs, new_log_count))
 		return 0;
 
 	/*


