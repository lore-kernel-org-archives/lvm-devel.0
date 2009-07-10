From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 10 Jul 2009 08:45:41 -0400
Subject: [PATCH] Remove unused code vg_lock_and_read() and related flags.
Message-ID: <1247229941-6147-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    8 -------
 lib/metadata/metadata.c          |   44 --------------------------------------
 2 files changed, 0 insertions(+), 52 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5aa0d56..c447b87 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -96,10 +96,6 @@ struct pv_segment;
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 #define FMT_RESTRICTED_READAHEAD 0x00000200U	/* Readahead restricted to 2-120? */
 
-/* LVM2 external library flags */
-#define CORRECT_INCONSISTENT    0x00000001U /* Correct inconsistent metadata */
-#define FAIL_INCONSISTENT       0x00000002U /* Fail if metadata inconsistent */
-
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
@@ -384,10 +380,6 @@ int is_orphan(const pv_t *pv);
 int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_from,
 		       struct volume_group *vg_to);
-vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
-		       const char *vgid,
-		       uint32_t lock_flags, uint32_t status_flags,
-		       uint32_t misc_flags);
 uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname);
 
 /*
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0c155fd..9e9e1df 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2736,50 +2736,6 @@ int vg_check_status(const struct volume_group *vg, uint32_t status)
 }
 
 /*
- * vg_lock_and_read - consolidate vg locking, reading, and status flag checking
- *
- * Returns:
- * NULL - failure
- * non-NULL - success; volume group handle
- */
-vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
-		       const char *vgid,
-		       uint32_t lock_flags, uint32_t status_flags,
-		       uint32_t misc_flags)
-{
-	struct volume_group *vg;
-	int consistent = 1;
-
-	if (!(misc_flags & CORRECT_INCONSISTENT))
-		consistent = 0;
-
-	if (!validate_name(vg_name)) {
-		log_error("Volume group name %s has invalid characters",
-			  vg_name);
-		return NULL;
-	}
-
-	if (!lock_vol(cmd, vg_name, lock_flags)) {
-		log_error("Can't get lock for %s", vg_name);
-		return NULL;
-	}
-
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)) ||
-	    ((misc_flags & FAIL_INCONSISTENT) && !consistent)) {
-		log_error("Volume group \"%s\" not found", vg_name);
-		unlock_and_release_vg(cmd, vg, vg_name);
-		return NULL;
-	}
-
-	if (!vg_check_status(vg, status_flags)) {
-		unlock_and_release_vg(cmd, vg, vg_name);
-		return NULL;
-	}
-
-	return vg;
-}
-
-/*
  * Create a (vg_t) volume group handle from a struct volume_group pointer and a
  * possible failure code or zero for success.
  */
-- 
1.6.0.6


