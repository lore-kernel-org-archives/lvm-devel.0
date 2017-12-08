From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Dec 2017 07:22:09 -0500
Subject: master - thin: regression fix for metadata checking
Message-ID: <201712081222.vB8CM9OD007383@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=71485ebfc759299610e279a91b97215b556295df
Commit:        71485ebfc759299610e279a91b97215b556295df
Parent:        455b26b8dbdd05ec773a84da2ef64b669c80e194
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 8 13:09:45 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 8 13:21:15 2017 +0100

thin: regression fix for metadata checking

Fix regression from commit f173274fe4888cc73eb573cf2c6913f54641c1aa
and restore support for 'disabled' checking via lvm.conf.
---
 lib/activate/dev_manager.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index ced50fa..2faf1cc 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1913,7 +1913,12 @@ static int _pool_callback(struct dm_tree_node *node,
 	long buf[64 / sizeof(long)]; /* buffer for short disk header (64B) */
 	int args = 0;
 	char *mpath;
-	const char *argv[19] = { 0 }; /* Max supported 15 args */
+	const char *argv[19] = { /* Max supported 15 args */
+		find_config_tree_str_allow_empty(pool_lv->vg->cmd, data->exec, NULL)
+	};
+
+	if (!*argv[0]) /* *_check tool is unconfigured/disabled with "" setting */
+		return 1;
 
 	if (!(mpath = lv_dmpath_dup(data->dm->mem, mlv))) {
 		log_error("Failed to build device path for checking pool metadata %s.",
@@ -1947,9 +1952,6 @@ static int _pool_callback(struct dm_tree_node *node,
 		}
 	}
 
-	if (!(argv[0] = find_config_tree_str_allow_empty(pool_lv->vg->cmd, data->exec, NULL)))
-		return 1; /* Checking disabled */
-
 	if (!(cn = find_config_tree_array(mlv->vg->cmd, data->opts, NULL))) {
 		log_error(INTERNAL_ERROR "Unable to find configuration for pool check options.");
 		return 0;


