From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  6 Aug 2013 14:23:12 +0000 (UTC)
Subject: master - thin: use pipe_open instead of popen
Message-ID: <20130806142312.7EE5A61268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=139a62fc0bbe45318c7ca25cd8ee2dc990c95a9d
Commit:        139a62fc0bbe45318c7ca25cd8ee2dc990c95a9d
Parent:        f6dd5a294b9beaf1d3ef68385eeeb8d55ec3a344
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 6 15:21:42 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 6 16:19:31 2013 +0200

thin: use pipe_open instead of popen

Use new function to directly exec command and read its output.
---
 tools/lvconvert.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f008954..5d796e7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1968,6 +1968,7 @@ static int _lvconvert_thinpool_repair(struct cmd_context *cmd,
 	uint64_t trans_id;
 	struct logical_volume *pmslv;
 	struct logical_volume *mlv = first_seg(pool_lv)->metadata_lv;
+	struct pipe_data pdata;
 	FILE *f;
 
 	if (!thin_repair[0]) {
@@ -1975,11 +1976,17 @@ static int _lvconvert_thinpool_repair(struct cmd_context *cmd,
 		return 0; /* Checking disabled */
 	}
 
+	pmslv = pool_lv->vg->pool_metadata_spare_lv;
+
 	/* Check we have pool metadata spare LV */
 	if (!handle_pool_metadata_spare(pool_lv->vg, 0, NULL, 1))
 		return_0;
 
-	pmslv = pool_lv->vg->pool_metadata_spare_lv;
+	if (pmslv != pool_lv->vg->pool_metadata_spare_lv) {
+		if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
+			return_0;
+		pmslv = pool_lv->vg->pool_metadata_spare_lv;
+	}
 
 	if (!(dm_name = dm_build_dm_name(cmd->mem, mlv->vg->name,
 					 mlv->name, NULL)) ||
@@ -2050,13 +2057,12 @@ static int _lvconvert_thinpool_repair(struct cmd_context *cmd,
 	}
 
 	if (thin_dump[0]) {
-		if (dm_snprintf(meta_path, sizeof(meta_path), "%s %s", thin_dump, pms_path) < 0) {
-			log_error("Command cannot fit into buffer.");
-			goto deactivate_mlv;
-		}
+		argv[0] = thin_dump;
+		argv[1] = pms_path;
+		argv[2] = NULL;
 
-		if (!(f = popen(meta_path, "r")))
-			log_warn("WARNING: Cannot read output from %s.", meta_path);
+		if (!(f = pipe_open(cmd, argv, 0, &pdata)))
+			log_warn("WARNING: Cannot read output from %s %s.", thin_dump, pms_path);
 		else {
 			/*
 			 * Scan only the 1st. line for transation id.
@@ -2073,8 +2079,8 @@ static int _lvconvert_thinpool_repair(struct cmd_context *cmd,
 					  first_seg(pool_lv)->transaction_id,
 					  pool_lv->vg->name, pool_lv->name, trans_id,
 					  pms_path);
-			if (pclose(f))
-				log_sys_error("popen", thin_dump);
+
+			(void) pipe_close(&pdata); /* killing pipe */
 		}
 	}
 


