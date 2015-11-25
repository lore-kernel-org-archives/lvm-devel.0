From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 25 Nov 2015 10:44:20 +0000 (UTC)
Subject: master - cleanup: rename lv_ondisk to lv_committed
Message-ID: <20151125104420.E372661042@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=66c7fa4a44e322720ff67f0e46ed91d4d8113c72
Commit:        66c7fa4a44e322720ff67f0e46ed91d4d8113c72
Parent:        4312b096359b336d6f4ba52679a0f594854ba7ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 25 11:10:32 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 25 11:39:26 2015 +0100

cleanup: rename lv_ondisk to lv_committed

Patch has no functional change.
---
 lib/locking/file_locking.c |   14 +++++++-------
 lib/locking/no_locking.c   |   16 +++++++++-------
 lib/metadata/lv.h          |    2 +-
 lib/metadata/metadata.c    |    4 ++--
 4 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 0595752..849bc3c 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -92,18 +92,18 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_UNLOCK:
 			log_very_verbose("Unlocking LV %s%s%s", resource, origin_only ? " without snapshots" : "", revert ? " (reverting)" : "");
-			if (!lv_resume_if_active(cmd, resource, origin_only, 0, revert, lv_ondisk(lv)))
+			if (!lv_resume_if_active(cmd, resource, origin_only, 0, revert, lv_committed(lv)))
 				return 0;
 			break;
 		case LCK_NULL:
 			log_very_verbose("Locking LV %s (NL)", resource);
-			if (!lv_deactivate(cmd, resource, lv_ondisk(lv)))
+			if (!lv_deactivate(cmd, resource, lv_committed(lv)))
 				return 0;
 			break;
 		case LCK_READ:
 			log_very_verbose("Locking LV %s (R)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 0, lv->status & LV_NOSCAN ? 1 : 0,
-						     lv->status & LV_TEMPORARY ? 1 : 0, lv_ondisk(lv)))
+			if (!lv_activate_with_filter(cmd, resource, 0, (lv->status & LV_NOSCAN) ? 1 : 0,
+						     (lv->status & LV_TEMPORARY) ? 1 : 0, lv_committed(lv)))
 				return 0;
 			break;
 		case LCK_PREAD:
@@ -111,13 +111,13 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			break;
 		case LCK_WRITE:
 			log_very_verbose("Locking LV %s (W)%s", resource, origin_only ? " without snapshots" : "");
-			if (!lv_suspend_if_active(cmd, resource, origin_only, 0, lv_ondisk(lv), lv))
+			if (!lv_suspend_if_active(cmd, resource, origin_only, 0, lv_committed(lv), lv))
 				return 0;
 			break;
 		case LCK_EXCL:
 			log_very_verbose("Locking LV %s (EX)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 1, lv->status & LV_NOSCAN ? 1 : 0,
-						     lv->status & LV_TEMPORARY ? 1 : 0, lv_ondisk(lv)))
+			if (!lv_activate_with_filter(cmd, resource, 1, (lv->status & LV_NOSCAN) ? 1 : 0,
+						     (lv->status & LV_TEMPORARY) ? 1 : 0, lv_committed(lv)))
 				return 0;
 			break;
 		default:
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index 613877a..6b0ac63 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -44,17 +44,19 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 	case LCK_LV:
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_NULL:
-			return lv_deactivate(cmd, resource, lv_ondisk(lv));
+			return lv_deactivate(cmd, resource, lv_committed(lv));
 		case LCK_UNLOCK:
-			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0, (flags & LCK_REVERT) ? 1 : 0, lv_ondisk(lv));
+			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0,
+						   (flags & LCK_REVERT) ? 1 : 0, lv_committed(lv));
 		case LCK_READ:
-			return lv_activate_with_filter(cmd, resource, 0, lv->status & LV_NOSCAN ? 1 : 0,
-						       lv->status & LV_TEMPORARY ? 1 : 0, lv_ondisk(lv));
+			return lv_activate_with_filter(cmd, resource, 0, (lv->status & LV_NOSCAN) ? 1 : 0,
+						       (lv->status & LV_TEMPORARY) ? 1 : 0, lv_committed(lv));
 		case LCK_WRITE:
-			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0, 0, lv_ondisk(lv), lv);
+			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0, 0,
+						    lv_committed(lv), lv);
 		case LCK_EXCL:
-			return lv_activate_with_filter(cmd, resource, 1, lv->status & LV_NOSCAN ? 1 : 0,
-						       lv->status & LV_TEMPORARY ? 1 : 0, lv_ondisk(lv));
+			return lv_activate_with_filter(cmd, resource, 1, (lv->status & LV_NOSCAN) ? 1 : 0,
+						       (lv->status & LV_TEMPORARY) ? 1 : 0, lv_committed(lv));
 		default:
 			break;
 		}
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 172d29f..2f1e4f9 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -113,7 +113,7 @@ int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 		     enum activation_change activate, int needs_exlusive);
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
-const struct logical_volume *lv_ondisk(const struct logical_volume *lv);
+const struct logical_volume *lv_committed(const struct logical_volume *lv);
 struct profile *lv_config_profile(const struct logical_volume *lv);
 char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_lock_args_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 52d76c3..7ee928d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5531,7 +5531,7 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl)
 	return dm_pool_end_object(mem);
 }
 
-const struct logical_volume *lv_ondisk(const struct logical_volume *lv)
+const struct logical_volume *lv_committed(const struct logical_volume *lv)
 {
 	struct volume_group *vg;
 	struct logical_volume *found_lv;
@@ -5545,7 +5545,7 @@ const struct logical_volume *lv_ondisk(const struct logical_volume *lv)
 	vg = lv->vg->vg_committed;
 
 	if (!(found_lv = find_lv_in_vg_by_lvid(vg, &lv->lvid))) {
-		log_error(INTERNAL_ERROR "LV %s (UUID %s) not found in ondisk metadata.",
+		log_error(INTERNAL_ERROR "LV %s (UUID %s) not found in committed metadata.",
 			  display_lvname(lv), lv->lvid.s);
 		return NULL;
 	}


