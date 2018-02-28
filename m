From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:52 -0500
Subject: master - cleanup: indent
Message-ID: <201802282022.w1SKMqnd009895@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=406d6de651fd1ae3bda80f3597d7aa8733b0389a
Commit:        406d6de651fd1ae3bda80f3597d7aa8733b0389a
Parent:        16c209c613b35307105e7d022a95f58f897243aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 26 14:44:51 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:15:55 2018 +0100

cleanup: indent

---
 lib/metadata/lv_manip.c |    5 +++--
 tools/lvchange.c        |    3 ++-
 tools/lvconvert.c       |    2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1e2cfc6..044214c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1049,12 +1049,13 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 	}
 
 	if (lv_is_raid_image(lv)) {
-		/* Calculate the amount of extents to reduce per rmate/rimage LV */
+		/* Calculate the amount of extents to reduce per rmeta/rimage LV */
 		uint32_t rimage_extents;
 		struct lv_segment *seg1 = first_seg(lv);
 
 		/* FIXME: avoid extra seg_is_*() conditionals here */
-		rimage_extents = raid_rimage_extents(seg1->segtype, area_reduction, seg_is_any_raid0(seg) ? 0 : _raid_stripes_count(seg),
+		rimage_extents = raid_rimage_extents(seg1->segtype, area_reduction,
+						     seg_is_any_raid0(seg) ? 0 : _raid_stripes_count(seg),
 						     seg_is_raid10(seg) ? 1 :_raid_data_copies(seg));
 		if (!rimage_extents)
 			return 0;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 83dbf97..288b04c 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1374,6 +1374,7 @@ static int _lvchange_activate_check(struct cmd_context *cmd,
 int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	int ret;
+	int do_activate = is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY));
 
 	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 : arg_int_value(cmd, poll_ARG, DEFAULT_BACKGROUND_POLLING));
 	cmd->handles_missing_pvs = 1;
@@ -1387,7 +1388,7 @@ int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv)
 	cmd->include_active_foreign_vgs = 1;
 
 	/* Allow deactivating if locks fail. */
-	if (is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
+	if (do_activate)
 		cmd->lockd_vg_enforce_sh = 1;
 
 	ret = process_each_lv(cmd, argc, argv, NULL, NULL, 0,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8006699..63f0715 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1948,7 +1948,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	 * LV_foo specification because this LV is not processed by process_each_lv.
 	 */
 	if (!validate_snapshot_origin(org))
-                return_0;
+		return_0;
 
 	log_warn("WARNING: Converting logical volume %s to snapshot exception store.",
 		 snap_name);


