From: dongmao zhang <dmzhang@suse.com>
Date: Sun,  6 Jan 2013 16:46:36 +0800
Subject: [PATCH 2/2] support mirrored log in cluster evironment
In-Reply-To: <1357461996-368-1-git-send-email-dmzhang@suse.com>
References: <1357461996-368-1-git-send-email-dmzhang@suse.com>
Message-ID: <1357461996-368-3-git-send-email-dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: dongmao zhang <deanraccoon@gmail.com>

1.remove the limits when meeting mirrored log in cluster.

2.If core log ,use mirror's UUID(change last 4 bytes to CORE.
Because when in cluster mirrored log, UUID conflicts occurs between
the main mirror's log and mirrored log(which is CORE) itself.
---
 lib/metadata/mirror.c |   23 -----------------------
 lib/mirror/mirrored.c |    4 +++-
 tools/lvconvert.c     |    9 ---------
 3 files changed, 3 insertions(+), 33 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 4fee763..1a67832 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1889,10 +1889,6 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	unsigned old_log_count;
 	int r = 0;
 
-	if (vg_is_clustered(lv->vg) && (log_count > 1)) {
-		log_error("Log type, \"mirrored\", is unavailable to cluster mirrors");
-		return 0;
-	}
 
 	if (dm_list_size(&lv->segments) != 1) {
 		log_error("Multiple-segment mirror is not supported");
@@ -2056,25 +2052,6 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (vg_is_clustered(lv->vg)) {
-		/* FIXME: review check of lv_is_active_remotely */
-		/* FIXME: move this test out of this function */
-		/* Skip test for pvmove mirrors, it can use local mirror */
-		if (!(lv->status & (PVMOVE | LOCKED)) &&
-		    !_cluster_mirror_is_available(lv)) {
-			log_error("Shared cluster mirrors are not available.");
-			return 0;
-		}
-
-		/*
-		 * No mirrored logs for cluster mirrors until
-		 * log daemon is multi-threaded.
-		 */
-		if (log_count > 1) {
-			log_error("Log type, \"mirrored\", is unavailable to cluster mirrors");
-			return 0;
-		}
-	}
 
 	/* For corelog mirror, activation code depends on
 	 * the global mirror_in_sync status. As we are adding
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 7ce8475..335772f 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -366,12 +366,14 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 			return 0;
 		}
 	} else {
-		/* If core log, use mirror's UUID and set DM_CORELOG flag */
+		/* If core log, use mirror's (UUID + CORE) and set DM_CORELOG flag */
 		if (!(log_dlid = build_dm_uuid(mem, seg->lv->lvid.s, NULL))) {
 			log_error("Failed to build uuid for mirror LV %s.",
 				  seg->lv->name);
 			return 0;
 		}
+		memcpy(&(log_dlid[strlen(log_dlid)-4]),"CORE",4);
+
 		log_flags |= DM_CORELOG;
 	}
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5bda00f..d5cbb97 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1096,15 +1096,6 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/*
-	 * No mirrored logs for cluster mirrors until
-	 * log daemon is multi-threaded.
-	 */
-	if ((*new_log_count == 2) && vg_is_clustered(lv->vg)) {
-		log_error("Log type, \"mirrored\", is unavailable to cluster mirrors");
-		return 0;
-	}
-
 	log_verbose("Setting logging type to %s", mirrorlog);
 
 	/*
-- 
1.7.3.4


