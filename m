From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:43 +0000 (UTC)
Subject: master - cleanup: drop cmd and constify lv for lv_refresh_suspend_resume()
Message-ID: <20160527134743.3F44060642@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=98b41db324a432db5860cb7dbea697a09bc4321e
Commit:        98b41db324a432db5860cb7dbea697a09bc4321e
Parent:        cb49ceeabaa011f51aa20c1a66c85ecbcb2c36a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 20 10:55:05 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

cleanup: drop cmd and constify lv for lv_refresh_suspend_resume()

Like with most other lv_manip* functions take just LV arg and get cmd
from embeded pointer when needed.
---
 lib/locking/lvmlockd.c           |    2 +-
 lib/metadata/cache_manip.c       |    2 +-
 lib/metadata/lv_manip.c          |    4 +++-
 lib/metadata/metadata-exported.h |    4 ++--
 tools/toollib.c                  |    2 +-
 5 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index c55f2b5..d718ac9 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -391,7 +391,7 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 
 static int _refresh_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg)
 {
-	if (!lv_refresh_suspend_resume(cmd, vg->sanlock_lv)) {
+	if (!lv_refresh_suspend_resume(vg->sanlock_lv)) {
 		log_error("Failed to refresh %s.", vg->sanlock_lv->name);
 		return 0;
 	}
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 3e8c5c7..4d84fe1 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -379,7 +379,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	 * ATM this is workaround for missing cache sync when cache gets clean
 	 */
 	if (1) {
-		if (!lv_refresh_suspend_resume(lock_lv->vg->cmd, lock_lv))
+		if (!lv_refresh_suspend_resume(lock_lv))
 			return_0;
 	}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b941979..625cea6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1373,8 +1373,10 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 	return 1;
 }
 
-int lv_refresh_suspend_resume(struct cmd_context *cmd, struct logical_volume *lv)
+int lv_refresh_suspend_resume(const struct logical_volume *lv)
 {
+	struct cmd_context *cmd = lv->vg->cmd;
+
 	if (!cmd->partial_activation && lv_is_partial(lv)) {
 		log_error("Refusing refresh of partial LV %s."
 			  " Use '--activationmode partial' to override.",
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1a9d5d9..a88ba1e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -801,7 +801,7 @@ int lv_empty(struct logical_volume *lv);
 /* Empty an LV and add error segment */
 int replace_lv_with_error_segment(struct logical_volume *lv);
 
-int lv_refresh_suspend_resume(struct cmd_context *cmd, struct logical_volume *lv);
+int lv_refresh_suspend_resume(const struct logical_volume *lv);
 
 /* Entry point for all LV extent allocations */
 int lv_extend(struct logical_volume *lv,
diff --git a/tools/toollib.c b/tools/toollib.c
index 12dddc8..2f03a91 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1099,7 +1099,7 @@ int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 						display_lvname(lv), display_lvname(snapshot_lv));
 	}
 
-	if (!lv_refresh_suspend_resume(cmd, lv))
+	if (!lv_refresh_suspend_resume(lv))
 		return_0;
 
 	/*


