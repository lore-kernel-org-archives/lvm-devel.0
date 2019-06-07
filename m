From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:53 -0400
Subject: master - add a warning message when updating old metadata
Message-ID: <201906072108.x57L8rJE005353@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=015b906069a989552c09f61d7230b000d0a1f0f0
Commit:        015b906069a989552c09f61d7230b000d0a1f0f0
Parent:        5dd32680b0cbe468c07b3187bbb8922323b848f8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 6 13:51:54 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

add a warning message when updating old metadata

in an mda that had previously not been updated
---
 lib/metadata/metadata.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5eabfa6..2d3ff1c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2947,6 +2947,7 @@ int vg_write(struct volume_group *vg)
 	struct pv_list *pvl, *pvl_safe, *new_pvl;
 	struct metadata_area *mda;
 	struct lv_list *lvl;
+	struct device *mda_dev;
 	int revert = 0, wrote = 0;
 
 	if (vg_is_shared(vg)) {
@@ -3040,14 +3041,34 @@ int vg_write(struct volume_group *vg)
 
 	/* Write to each copy of the metadata area */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		mda_dev = mda_get_device(mda);
+
 		if (mda->status & MDA_FAILED)
 			continue;
+
+		/*
+		 * When the scan and vg_read find old metadata in an mda, they
+		 * leave the info struct in lvmcache, and leave the mda in
+		 * info->mdas.  That means we use the mda here to write new
+		 * metadata into.  This means that a command writing a VG will
+		 * automatically update old metadata to the latest.
+		 *
+		 * This can also happen if the metadata was ignored on this
+		 * dev, and then it's later changed to not ignored, and
+		 * we see the old metadata.
+		 */
+		if (lvmcache_has_old_metadata(vg->cmd, vg->name, (const char *)&vg->id, mda_dev)) {
+			log_warn("WARNING: updating old metadata to %u on %s for VG %s.",
+				 vg->seqno, dev_name(mda_dev), vg->name);
+		}
+
 		if (!mda->ops->vg_write) {
 			log_error("Format does not support writing volume"
 				  "group metadata areas");
 			revert = 1;
 			break;
 		}
+
 		if (!mda->ops->vg_write(vg->fid, vg, mda)) {
 			if (vg->cmd->handles_missing_pvs) {
 				log_warn("WARNING: Failed to write an MDA of VG %s.", vg->name);


