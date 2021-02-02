From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Feb 2021 20:23:58 +0000 (GMT)
Subject: main - lvcreate: use lv_passes_readonly_filter
Message-ID: <20210202202358.2E3AB383E833@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51c83f14837c8647c3522abb23707da3ece2085c
Commit:        51c83f14837c8647c3522abb23707da3ece2085c
Parent:        8454ce66c511438ef0d9da3d3b0bac2a5a3d8f2b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 2 19:53:59 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 2 21:23:39 2021 +0100

lvcreate: use lv_passes_readonly_filter

Check if created LV is going to be activated read-only
because such LV cannot be zeroed (equals to use
option '-pr').
---
 WHATS_NEW               | 1 +
 lib/activate/activate.c | 5 +++++
 lib/activate/activate.h | 2 ++
 lib/metadata/lv_manip.c | 6 ++++++
 4 files changed, 14 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index c6be9b481..42ea4f550 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.12 - 
 ===================================
+  Check if lvcreate passes read_only_volume_list with tags and skips zeroing.
   Allocation prints better error when metadata cannot fit on a single PV.
   Pvmove can better resolve full thin-pool tree move.
   Limit pool metadata spare to 16GiB.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7ed644113..de866fb6c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -466,6 +466,11 @@ static int _passes_readonly_filter(struct cmd_context *cmd,
 	return _lv_passes_volumes_filter(cmd, lv, cn, activation_read_only_volume_list_CFG);
 }
 
+int lv_passes_readonly_filter(const struct logical_volume *lv)
+{
+	return _passes_readonly_filter(lv->vg->cmd, lv);
+}
+
 int library_version(char *version, size_t size)
 {
 	if (!activation())
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 3f4d128be..53c8631b4 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -208,6 +208,8 @@ int lvs_in_vg_opened(const struct volume_group *vg);
 
 int lv_is_active(const struct logical_volume *lv);
 
+int lv_passes_readonly_filter(const struct logical_volume *lv);
+
 /* Check is any component LV is active */
 const struct logical_volume *lv_component_is_active(const struct logical_volume *lv);
 const struct logical_volume *lv_holder_is_active(const struct logical_volume *lv);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d101fa582..29c95ff63 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7987,6 +7987,12 @@ static int _should_wipe_lv(struct lvcreate_params *lp,
 	     first_seg(first_seg(lv)->pool_lv)->zero_new_blocks))
 		return 0;
 
+	if (warn && (lv_passes_readonly_filter(lv))) {
+		log_warn("WARNING: Read-only activated logical volume %s not zeroed.",
+			 display_lvname(lv));
+		return 0;
+	}
+
 	/* Cannot zero read-only volume */
 	if ((lv->status & LVM_WRITE) &&
 	    (lp->zero || lp->wipe_signatures))


