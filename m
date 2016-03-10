From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:02 +0000 (UTC)
Subject: master - lvconvert: uncache handles missing PV
Message-ID: <20160310174002.ECD0C60EAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=569ba79abfef9b6cfc8d7c433834df5599f3188c
Commit:        569ba79abfef9b6cfc8d7c433834df5599f3188c
Parent:        29d1533a497be922dc114524b83e926cbb63c34a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 8 10:47:27 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:53 2016 +0100

lvconvert: uncache handles missing PV

Allow to process with --uncache when some PVs are missing in VG.

So it's now possible to --uncache cached LV if the cache-pool
has missing PV.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   48 +++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f52b879..04d32d6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.146 - 
 =================================
+  Support --uncache with missing PVs.
   Tidy report field names, headings and widths.
   Add vgscan --notifydbus to send a dbus notification.
   Add dbus notification from commands after a PV/VG/LV changes state.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index db1c7f7..2b5080f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1997,6 +1997,9 @@ static int _lvconvert_uncache(struct cmd_context *cmd,
 			      struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
+	struct lv_segment *seg;
+	struct logical_volume *remove_lv;
+
 	if (lv_is_thin_pool(lv))
 		lv = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
 
@@ -2006,10 +2009,49 @@ static int _lvconvert_uncache(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!lv_remove_single(cmd, first_seg(lv)->pool_lv, (force_t) lp->force, 0))
+	seg = first_seg(lv);
+
+	if (lv_is_partial(seg_lv(seg, 0))) {
+		log_warn("WARNING: Cache origin logical volume %s is missing.",
+			 display_lvname(seg_lv(seg, 0)));
+		remove_lv = lv; /* When origin is missing, drop everything */
+	} else
+		remove_lv = seg->pool_lv;
+
+	if (lv_is_partial(seg_lv(first_seg(seg->pool_lv), 0)))
+		log_warn("WARNING: Cache pool data logical volume %s is missing.",
+			 display_lvname(seg_lv(first_seg(seg->pool_lv), 0)));
+
+	if (lv_is_partial(first_seg(seg->pool_lv)->metadata_lv))
+		log_warn("WARNING: Cache pool metadata logical volume %s is missing.",
+			 display_lvname(first_seg(seg->pool_lv)->metadata_lv));
+
+	/* TODO: Check for failed cache as well to get prompting? */
+	if (lv_is_partial(lv)) {
+		if (strcmp("writethrough", get_cache_mode_name(first_seg(seg->pool_lv)))) {
+			if (!lp->force) {
+				log_error("Conversion aborted.");
+				log_error("Cannot uncache writethrough cache volume %s without --force.",
+					  display_lvname(lv));
+				return 0;
+			}
+			log_warn("WARNING: Uncaching of partially missing writethrough cache volume %s might destroy your data.",
+				 display_lvname(first_seg(seg->pool_lv)->metadata_lv));
+		}
+
+		if (!lp->yes &&
+		    yes_no_prompt("Do you really want to uncache %s? with missing LVs [y/n]: ",
+				  display_lvname(lv)) == 'n') {
+			log_error("Conversion aborted.");
+			return 0;
+		}
+	}
+
+	if (!lvremove_single(cmd, remove_lv, NULL))
 		return_0;
 
-	log_print_unless_silent("Logical volume %s is not cached.", display_lvname(lv));
+	if (remove_lv != lv)
+		log_print_unless_silent("Logical volume %s is not cached.", display_lvname(lv));
 
 	return 1;
 }
@@ -3421,7 +3463,7 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
 	uint32_t lockd_state = 0;
 
-	if (lp->repair) {
+	if (lp->repair || lp->uncache) {
 		init_ignore_suspended_devices(1);
 		cmd->handles_missing_pvs = 1;
 	}


