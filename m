From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 7 Dec 2017 15:03:50 -0500
Subject: master - cleanup: reorder calling of pool checking tools
Message-ID: <201712072003.vB7K3oMf005657@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f173274fe4888cc73eb573cf2c6913f54641c1aa
Commit:        f173274fe4888cc73eb573cf2c6913f54641c1aa
Parent:        820b1b98fce4a370e9b54ffbc8cbe4b3d0e962f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 7 17:49:15 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 7 21:00:39 2017 +0100

cleanup: reorder calling of pool checking tools

Test for zero header before even starting to create argument list for
execution of thin/cache_check tool.
---
 lib/activate/dev_manager.c |   70 ++++++++++++++++++++++---------------------
 1 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index c050f34..ced50fa 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1912,11 +1912,42 @@ static int _pool_callback(struct dm_tree_node *node,
 	const struct logical_volume *mlv = first_seg(pool_lv)->metadata_lv;
 	long buf[64 / sizeof(long)]; /* buffer for short disk header (64B) */
 	int args = 0;
-	const char *argv[19] = { /* Max supported 15 args */
-		find_config_tree_str_allow_empty(pool_lv->vg->cmd, data->exec, NULL) /* argv[0] */
-	};
+	char *mpath;
+	const char *argv[19] = { 0 }; /* Max supported 15 args */
+
+	if (!(mpath = lv_dmpath_dup(data->dm->mem, mlv))) {
+		log_error("Failed to build device path for checking pool metadata %s.",
+			  display_lvname(mlv));
+		return 0;
+	}
+
+	if (data->skip_zero) {
+		if ((fd = open(mpath, O_RDONLY)) < 0) {
+			log_sys_error("open", mpath);
+			return 0;
+		}
+		/* let's assume there is no problem to read 64 bytes */
+		if (read(fd, buf, sizeof(buf)) < (int)sizeof(buf)) {
+			log_sys_error("read", mpath);
+			if (close(fd))
+				log_sys_error("close", mpath);
+			return 0;
+		}
+		for (ret = 0; ret < (int) DM_ARRAY_SIZE(buf); ++ret)
+			if (buf[ret])
+				break;
+
+		if (close(fd))
+			log_sys_error("close", mpath);
+
+		if (ret == (int) DM_ARRAY_SIZE(buf)) {
+			log_debug_activation("Metadata checking skipped, detected empty disk header on %s.",
+					     mpath);
+			return 1;
+		}
+	}
 
-	if (!*argv[0])
+	if (!(argv[0] = find_config_tree_str_allow_empty(pool_lv->vg->cmd, data->exec, NULL)))
 		return 1; /* Checking disabled */
 
 	if (!(cn = find_config_tree_array(mlv->vg->cmd, data->opts, NULL))) {
@@ -1939,36 +1970,7 @@ static int _pool_callback(struct dm_tree_node *node,
 		return 0;
 	}
 
-	if (!(argv[++args] = lv_dmpath_dup(data->dm->mem, mlv))) {
-		log_error("Failed to build pool metadata path.");
-		return 0;
-	}
-
-	if (data->skip_zero) {
-		if ((fd = open(argv[args], O_RDONLY)) < 0) {
-			log_sys_error("open", argv[args]);
-			return 0;
-		}
-		/* let's assume there is no problem to read 64 bytes */
-		if (read(fd, buf, sizeof(buf)) < (int)sizeof(buf)) {
-			log_sys_error("read", argv[args]);
-			if (close(fd))
-				log_sys_error("close", argv[args]);
-			return 0;
-		}
-		for (ret = 0; ret < (int) DM_ARRAY_SIZE(buf); ++ret)
-			if (buf[ret])
-				break;
-
-		if (close(fd))
-			log_sys_error("close", argv[args]);
-
-		if (ret == (int) DM_ARRAY_SIZE(buf)) {
-			log_debug_activation("%s skipped, detect empty disk header on %s.",
-					     argv[0], argv[args]);
-			return 1;
-		}
-	}
+	argv[++args] = mpath;
 
 	if (!(ret = exec_cmd(pool_lv->vg->cmd, (const char * const *)argv,
 			     &status, 0))) {


