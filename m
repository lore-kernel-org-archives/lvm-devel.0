From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:04 +0000 (UTC)
Subject: master - thin: reload external origin with last thin
Message-ID: <20161218185204.78F4A60E25@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7db46c4a39fd945f295a5bd4191bd48828072d24
Commit:        7db46c4a39fd945f295a5bd4191bd48828072d24
Parent:        c71fefad8d5e1d9a075553ab69791ddbf6bcb153
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 17 21:55:02 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:13:34 2016 +0100

thin: reload external origin with last thin

External origin could be activated as stand-alone device.
When the last thin LV is removed, external origin is no longer
the external origin and it's layer property was dropped.

Ensure dm table is correct by reloading external origin
(when it's active).
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 93fc93e..6d36890 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Fix dm table when the last user of active external origin is removed.
   Improve reported lvs status for active external origin volume.
   Fix table load for splitted RAID LV and require explicit activation.
   Always active splitted RAID LV exclusively locally.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1889998..92a6d44 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1264,6 +1264,7 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 	uint32_t count = extents;
 	uint32_t reduction;
 	struct logical_volume *pool_lv;
+	struct logical_volume *external_lv = NULL;
 
 	if (lv_is_merging_origin(lv)) {
 		log_debug_metadata("Dropping snapshot merge of %s to removed origin %s.",
@@ -1275,6 +1276,9 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 		if (!count)
 			break;
 
+		if (seg->external_lv)
+			external_lv = seg->external_lv;
+
 		if (seg->len <= count) {
 			if (seg->merge_lv) {
 				log_debug_metadata("Dropping snapshot merge of removed %s to origin %s.",
@@ -1341,6 +1345,12 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
 		return_0;
 
+	/* Removal of last user enforces refresh */
+	if (external_lv && !lv_is_external_origin(external_lv) &&
+	    lv_is_active(external_lv) &&
+	    !lv_update_and_reload(external_lv))
+		return_0;
+
 	return 1;
 }
 


