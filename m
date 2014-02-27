From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Feb 2014 13:55:34 +0000 (UTC)
Subject: master - cleanup: relocate segment flags
Message-ID: <20140227135534.AE82460FA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07ba047116b3fa5e07647ee79854b93c7fb27bb8
Commit:        07ba047116b3fa5e07647ee79854b93c7fb27bb8
Parent:        47b15b805ed5f605cd9ce93137df409c05fb0b46
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 27 14:46:11 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 27 14:46:11 2014 +0100

cleanup: relocate segment flags

Move flags for segments to segtype header where it seems more closely
related as the features are related to segtype and not activation.

Use unsigned #define - since it's more common in lvm2 source code
for bit flags.
---
 lib/activate/activate.h |   25 -------------------------
 lib/metadata/segtype.h  |   15 +++++++++++++++
 2 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index ad14a57..5b17b8a 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -52,31 +52,6 @@ struct lv_activate_opts {
 				 * that follows. */
 };
 
-/* target attribute flags */
-#define MIRROR_LOG_CLUSTERED	0x00000001U
-
-/* snapshot target attribute flags */
-enum {
-	SNAPSHOT_FEATURE_FIXED_LEAK		= (1 << 0), /* version 1.12 */
-};
-
-/* thin target attribute flags */
-enum {
-	/* bitfields - new features from 1.1 version */
-	THIN_FEATURE_DISCARDS			= (1 << 0),
-	THIN_FEATURE_EXTERNAL_ORIGIN		= (1 << 1),
-	THIN_FEATURE_HELD_ROOT			= (1 << 2),
-	THIN_FEATURE_BLOCK_SIZE			= (1 << 3),
-	THIN_FEATURE_DISCARDS_NON_POWER_2	= (1 << 4),
-	THIN_FEATURE_METADATA_RESIZE		= (1 << 5),
-	THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND	= (1 << 6),
-};
-
-/* raid target attribute flags */
-enum {
-	RAID_FEATURE_RAID10			= (1 << 0), /* version 1.3 */
-};
-
 void set_activation(int activation);
 int activation(void);
 
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 75429b4..4f060cd 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -141,6 +141,9 @@ struct segment_type *init_error_segtype(struct cmd_context *cmd);
 struct segment_type *init_free_segtype(struct cmd_context *cmd);
 struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 					  const char *name);
+
+#define RAID_FEATURE_RAID10			(1U << 0) /* version 1.3 */
+
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
@@ -149,6 +152,14 @@ int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
+#define THIN_FEATURE_DISCARDS			(1U << 0)
+#define THIN_FEATURE_EXTERNAL_ORIGIN		(1U << 1)
+#define THIN_FEATURE_HELD_ROOT			(1U << 2)
+#define THIN_FEATURE_BLOCK_SIZE			(1U << 3)
+#define THIN_FEATURE_DISCARDS_NON_POWER_2	(1U << 4)
+#define THIN_FEATURE_METADATA_RESIZE		(1U << 5)
+#define THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND	(1U << 6)
+
 #ifdef THIN_INTERNAL
 int init_thin_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
@@ -157,10 +168,14 @@ int init_thin_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 int init_cache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
+#define SNAPSHOT_FEATURE_FIXED_LEAK		(1U << 0) /* version 1.12 */
+
 #ifdef SNAPSHOT_INTERNAL
 struct segment_type *init_snapshot_segtype(struct cmd_context *cmd);
 #endif
 
+#define MIRROR_LOG_CLUSTERED			(1U << 0)
+
 #ifdef MIRRORED_INTERNAL
 struct segment_type *init_mirrored_segtype(struct cmd_context *cmd);
 #endif


