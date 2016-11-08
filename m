From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Nov 2016 15:01:54 +0000 (UTC)
Subject: master - raid: faster rmeta clearing
Message-ID: <20161108150154.6F35E60DB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ada5733c5652d456ffa138b0d07e6897824813b0
Commit:        ada5733c5652d456ffa138b0d07e6897824813b0
Parent:        9e03fc3c2ac682b4edc9a91eea7256e272a5bd71
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 8 11:54:28 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 8 16:00:14 2016 +0100

raid: faster rmeta clearing

Instead of clearing multiple rmeta device with sequential activation
process and waiting for udev for every _rmeta device separately,
activate all _rmeta devices first and then clear them and deactivate
afterwards.

Also update some tracing messages.

When anyhing goes wrong during clearing process, always try to
deactivate as much _rmeta devices as possible before fail.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   78 ++++++++++++++++++++++++++++------------------
 2 files changed, 48 insertions(+), 31 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2e95492..17fbdc0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  More efficiently prepare _rmeta devices when creating a new raid LV.
 
 Version 2.02.167 - 5th November 2016
 ====================================
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5adf81e..0643000 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3844,6 +3844,7 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	uint32_t fa, s;
 	int clear_metadata = 0;
 	uint32_t area_multiple = 1;
+	int fail;
 
 	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
 		return_0;
@@ -3917,45 +3918,60 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 			return_0;
 
-		for (s = 0; s < seg->area_count; s++) {
-			meta_lv = seg_metalv(seg, s);
-
-			if (test_mode()) {
-				lv_set_hidden(meta_lv);
-				continue;
+		if (test_mode())
+			log_verbose("Test mode: Skipping wiping of metadata areas.");
+		else {
+			fail = 0;
+			/* Activate all rmeta devices locally first (more efficient) */
+			for (s = 0; !fail && s < seg->area_count; s++) {
+				meta_lv = seg_metalv(seg, s);
+
+				if (!activate_lv_local(meta_lv->vg->cmd, meta_lv)) {
+					log_error("Failed to activate %s for clearing.",
+						  display_lvname(meta_lv));
+					fail = 1;
+				}
 			}
 
-			/* For clearing, simply activate locally */
-			if (!activate_lv_local(meta_lv->vg->cmd, meta_lv)) {
-				log_error("Failed to activate %s/%s for clearing",
-					  meta_lv->vg->name, meta_lv->name);
-				return 0;
-			}
+			/* Clear all rmeta devices */
+			for (s = 0; !fail && s < seg->area_count; s++) {
+				meta_lv = seg_metalv(seg, s);
 
-			log_verbose("Clearing metadata area of %s",
-				    display_lvname(meta_lv));
-			/*
-			 * Rather than wiping meta_lv->size, we can simply
-			 * wipe '1' to remove the superblock of any previous
-			 * RAID devices.  It is much quicker.
-			 */
-			if (!wipe_lv(meta_lv, (struct wipe_params)
-				     { .do_zero = 1, .zero_sectors = 1 })) {
-				log_error("Failed to zero %s/%s",
-					  meta_lv->vg->name, meta_lv->name);
-				return 0;
+				log_verbose("Clearing metadata area of %s.",
+					    display_lvname(meta_lv));
+				/*
+				 * Rather than wiping meta_lv->size, we can simply
+				 * wipe '1' to remove the superblock of any previous
+				 * RAID devices.  It is much quicker.
+				 */
+				if (!wipe_lv(meta_lv, (struct wipe_params)
+					     { .do_zero = 1, .zero_sectors = 1 })) {
+					stack;
+					fail = 1;
+				}
 			}
 
-			if (!deactivate_lv(meta_lv->vg->cmd, meta_lv)) {
-				log_error("Failed to deactivate %s/%s",
-					  meta_lv->vg->name, meta_lv->name);
-				return 0;
+			/* Deactivate all rmeta devices */
+			for (s = 0; s < seg->area_count; s++) {
+				meta_lv = seg_metalv(seg, s);
+
+				if (!deactivate_lv(meta_lv->vg->cmd, meta_lv)) {
+					log_error("Failed to deactivate %s after clearing.",
+						  display_lvname(meta_lv));
+					fail = 1;
+				}
+
+				/* Wipe any temporary tags required for activation. */
+				str_list_wipe(&meta_lv->tags);
 			}
-			lv_set_hidden(meta_lv);
 
-			/* Wipe any temporary tags required for activation. */
-			str_list_wipe(&meta_lv->tags);
+			if (fail)
+				/* Fail, after trying to deactivate all we could */
+				return_0;
 		}
+
+		for (s = 0; s < seg->area_count; s++)
+			lv_set_hidden(seg_metalv(seg, s));
 	}
 
 	seg->area_len += extents / area_multiple;


