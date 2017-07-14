From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 14 Jul 2017 09:53:53 -0400
Subject: master - lvconvert: allow reshaping in the cluster and on open devices
Message-ID: <201707141353.v6EDrreT025117@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6685460f5a918393edcde50d11f5cefb3a259df8
Commit:        6685460f5a918393edcde50d11f5cefb3a259df8
Parent:        f1b78665ef181ccd630209243b74df0627322a35
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 13 18:27:19 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jul 14 15:53:23 2017 +0200

lvconvert: allow reshaping in the cluster and on open devices

The previous commit fixed allocation/activation of reshape space.

Remove conditionals prohibiting reshaping in these cases.

Related: rhbz1447812
Related: rhbz1448116
Related: rhbz1461562
---
 lib/metadata/raid_manip.c |   62 ---------------------------------------------
 1 files changed, 0 insertions(+), 62 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 1966bb8..ada25ab 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -75,24 +75,6 @@ static int _rebuild_with_emptymeta_is_supported(struct cmd_context *cmd,
 	return 1;
 }
 
-/* https://bugzilla.redhat.com/1447812 check open count of @lv vs. @open_count */
-static int _check_lv_open_count(struct logical_volume *lv, int open_count) {
-	struct lvinfo info = { 0 };
-
-	if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)) {
-		log_error("lv_info failed: aborting.");
-		return 0;
-	}
-	if (info.open_count != open_count) {
-		log_error("Reshape is only supported when %s is not in use (e.g. unmount filesystem).",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	return 1;
-}
-
-
 /*
  * Ensure region size exceeds the minimum for @lv because
  * MD's bitmap is limited to tracking 2^21 regions.
@@ -2466,10 +2448,6 @@ static int _raid_reshape(struct logical_volume *lv,
 
 	seg->region_size = new_region_size;
 
-	/* https://bugzilla.redhat.com/1447812 also check open count */
-	if (!_check_lv_open_count(lv, 1))
-		return_0;
-
 	if (seg->area_count != 2 || old_image_count != seg->area_count) {
 		if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
 			return_0;
@@ -6310,27 +6288,6 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 	return r;
 }
 
-/* https://bugzilla.redhat.com/1447812 try opening LV exclusively */
-static int _lv_open_excl(struct logical_volume *lv, struct device **dev) {
-	char *dev_path;
-	size_t sz = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) + strlen(lv->name) + 2;
-
-	*dev = NULL;
-	if (!(dev_path = dm_pool_alloc(lv->vg->cmd->mem, sz)))
-		return_0;
-	if (dm_snprintf(dev_path, sz, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0)
-		return_0;
-	if (!(*dev = dev_create_file(dev_path, NULL, NULL, 0)))
-		return_0;
-	if (!dev_open_flags(*dev, O_EXCL, 1, 1)) {
-		log_error("Reshape is only supported when %s is not in use (e.g. unmount filesystem).",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	return 1;
-}
-
 /*
  * lv_raid_convert
  *
@@ -6380,7 +6337,6 @@ int lv_raid_convert(struct logical_volume *lv,
 	uint32_t region_size;
 	uint32_t data_copies = seg->data_copies;
 	uint32_t available_slvs, removed_slvs;
-	struct device *dev;
 	takeover_fn_t takeover_fn;
 
 	/* FIXME If not active, prompt and activate */
@@ -6445,31 +6401,13 @@ int lv_raid_convert(struct logical_volume *lv,
 	case 0:
 		break;
 	case 1:
-		/* Conversion of reshapable raids is the cluster is not supported yet. */
-		if (locking_is_clustered()) {
-			log_error("Conversion of %s not supported in the cluster.", display_lvname(lv));
-			return 0;
-		}
-
-		/* https://bugzilla.redhat.com/1447812 reject reshape on open LV */
-		if (!_check_lv_open_count(lv, 0))
-			return_0;
-		if (!_lv_open_excl(lv, &dev))
-			return_0;
-		if (!_check_lv_open_count(lv, 1)) {
-			dev_close(dev);
-			return_0;
-		}
-
 		if (!_raid_reshape(lv, new_segtype, yes, force,
 				   data_copies, region_size,
 				   stripes, stripe_size, allocate_pvs)) {
-			dev_close(dev);
 			log_error("Reshape request failed on LV %s.", display_lvname(lv));
 			return 0;
 		}
 
-		dev_close(dev);
 		return 1;
 	case 2:
 		log_error("Invalid conversion request on %s.", display_lvname(lv));


