From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 20 Apr 2016 23:34:55 +0000 (UTC)
Subject: master - display: Avoid internal snapshot LV names in msgs.
Message-ID: <20160420233455.61E8D61E05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0778d2e9857966e2d7e8f44c7f769fbdebb03a73
Commit:        0778d2e9857966e2d7e8f44c7f769fbdebb03a73
Parent:        2763b928de9b79ed9e144950446e59c0cac36a03
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 21 00:30:17 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 21 00:30:17 2016 +0100

display: Avoid internal snapshot LV names in msgs.

vg/snapshotN should not appear anywhere.

No code should be showing this, but it was noticed in some logs last
week and we can deal with it in display_lvname().
---
 WHATS_NEW                        |    1 +
 lib/display/display.c            |   14 ++++++++++++--
 lib/metadata/metadata-exported.h |    3 +++
 lib/metadata/snapshot_manip.c    |    5 +++++
 4 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 10f688d..65fefa1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.151 -
 =================================
+  Avoid internal snapshot LV names in messages.
   Autodetect and use /run/lock dir when available instead of /var/lock.
   lvchange --refresh for merging thin origin will retry to deactivate snapshot.
   Recognize in-progress snapshot merge for thin volumes from dm table.
diff --git a/lib/display/display.c b/lib/display/display.c
index a6387c6..0151d01 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -121,19 +121,29 @@ const char *get_percent_string(percent_type_t def)
 	return _percent_types[def];
 }
 
+static const char *_lv_name(const struct logical_volume *lv)
+{
+	/* Never try to display names of the internal snapshot structures. */
+	if (lv_is_snapshot(lv))
+		return find_cow(lv)->name;
+
+	return lv->name;
+}
+
 const char *display_lvname(const struct logical_volume *lv)
 {
 	char *name;
+	const char *lv_name = _lv_name(lv);
 	int r;
 
 	if ((lv->vg->cmd->display_lvname_idx + NAME_LEN) >= sizeof((lv->vg->cmd->display_buffer)))
 		lv->vg->cmd->display_lvname_idx = 0;
 
 	name = lv->vg->cmd->display_buffer + lv->vg->cmd->display_lvname_idx;
-	r = dm_snprintf(name, NAME_LEN, "%s/%s", lv->vg->name, lv->name);
+	r = dm_snprintf(name, NAME_LEN, "%s/%s", lv->vg->name, lv_name);
 
 	if (r < 0) {
-		log_error("Full LV name \"%s/%s\" is too long.", lv->vg->name, lv->name);
+		log_error("Full LV name \"%s/%s\" is too long.", lv->vg->name, lv_name);
 		return NULL;
 	}
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index fb2ffa3..039708e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1082,6 +1082,9 @@ struct lv_segment *find_snapshot(const struct logical_volume *lv);
 /* Given a cow LV, return its origin */
 struct logical_volume *origin_from_cow(const struct logical_volume *lv);
 
+/* Given an internal snapshot LV, return its cow */
+struct logical_volume *find_cow(const struct logical_volume *snap);
+
 void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 		       struct logical_volume *cow, uint32_t chunk_size, int merge);
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index d28d7c1..29b851f 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -34,6 +34,11 @@ int lv_is_cow(const struct logical_volume *lv)
 	return (!lv_is_thin_volume(lv) && !lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
 }
 
+struct logical_volume *find_cow(const struct logical_volume *snap)
+{
+	return first_seg(snap)->cow;
+}
+
 /*
  * Some kernels have a bug that they may leak space in the snapshot on crash.
  * If the kernel is buggy, we add some extra space.


