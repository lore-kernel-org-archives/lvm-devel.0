From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 17 Mar 2017 11:47:31 -0400
Subject: master - raid: check target version for shrink support
Message-ID: <201703171547.v2HFlVYV031505@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fec2ea76cf30f6333ff4dc6afb8a40b84d7abf7b
Commit:        fec2ea76cf30f6333ff4dc6afb8a40b84d7abf7b
Parent:        17a8f3d6f0fa26ab01d974af409d1d075d5815a0
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 17 16:46:33 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 17 16:46:33 2017 +0100

raid: check target version for shrink support

Starting with dm-raid target version 1.9.0 shrinking of mapped devices is supported.
Check for support being present in lvresize and lvreduce.

Related: rhbz1394048
---
 lib/metadata/lv_manip.c |   13 +++++++++++++
 lib/metadata/segtype.h  |    3 ++-
 lib/raid/raid.c         |    1 +
 3 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a249d29..0dfbad4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4773,6 +4773,19 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_raid(lv) &&
+	    lp->resize == LV_REDUCE) {
+		unsigned attrs;
+		const struct segment_type *segtype = first_seg(lv)->segtype;
+
+		if (!segtype->ops->target_present ||
+		    !segtype->ops->target_present(lv->vg->cmd, NULL, &attrs) ||
+		    !(attrs & RAID_FEATURE_SHRINK)) {
+			log_error("RAID module does not support shrinking.");
+			return 0;
+		}
+	}
+
 	if (lp->use_policies && !lv_is_cow(lv) && !lv_is_thin_pool(lv)) {
 		log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
 		return 0;
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index f99d3ad..2364db8 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -286,7 +286,8 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 #define RAID_FEATURE_RAID0			(1U << 1) /* version 1.7 */
 #define RAID_FEATURE_RESHAPING			(1U << 2) /* version 1.8 */
 #define RAID_FEATURE_RAID4			(1U << 3) /* ! version 1.8 or 1.9.0 */
-#define RAID_FEATURE_RESHAPE			(1U << 4) /* version 1.10.1 */
+#define RAID_FEATURE_SHRINK			(1U << 4) /* version 1.9.0 */
+#define RAID_FEATURE_RESHAPE			(1U << 5) /* version 1.10.1 */
 
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 6439a3e..df9796d 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -473,6 +473,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 	const struct raid_feature _features[] = {
 		{ 1, 3, 0, RAID_FEATURE_RAID10, SEG_TYPE_NAME_RAID10 },
 		{ 1, 7, 0, RAID_FEATURE_RAID0, SEG_TYPE_NAME_RAID0 },
+		{ 1, 9, 0, RAID_FEATURE_SHRINK, "shrinking" },
 		{ 1, 10, 1, RAID_FEATURE_RESHAPE, "reshaping" },
 	};
 


