From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  4 Jul 2014 10:32:08 +0000 (UTC)
Subject: master - cleanup: drop unneeded initialization
Message-ID: <20140704103208.3FD2260C22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86e116450ec32243f10abbe9b093bdeaab6e0f76
Commit:        86e116450ec32243f10abbe9b093bdeaab6e0f76
Parent:        1f72f8ed40a6cf72d424118cbb57d8a5961cc891
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 3 21:30:27 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 4 12:31:17 2014 +0200

cleanup: drop unneeded initialization

Code assigns this variable right after clearing.
---
 lib/config/config.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 2ed3db6..8148a18 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1142,7 +1142,7 @@ const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
-	int profile_applied = 0;
+	int profile_applied;
 	const struct dm_config_node *cn;
 
 	profile_applied = _apply_local_profile(cmd, profile);
@@ -1160,7 +1160,7 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
-	int profile_applied = 0;
+	int profile_applied;
 	const char *str;
 
 	profile_applied = _apply_local_profile(cmd, profile);
@@ -1181,7 +1181,7 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
-	int profile_applied = 0;
+	int profile_applied;
 	const char *str;
 
 	profile_applied = _apply_local_profile(cmd, profile);
@@ -1204,7 +1204,7 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
-	int profile_applied = 0;
+	int profile_applied;
 	int i;
 
 	profile_applied = _apply_local_profile(cmd, profile);
@@ -1225,7 +1225,7 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
-	int profile_applied = 0;
+	int profile_applied;
 	int i64;
 
 	profile_applied = _apply_local_profile(cmd, profile);
@@ -1246,7 +1246,7 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
-	int profile_applied = 0;
+	int profile_applied;
 	float f;
 
 	profile_applied = _apply_local_profile(cmd, profile);
@@ -1267,7 +1267,7 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
-	int profile_applied = 0;
+	int profile_applied;
 	int b;
 
 	profile_applied = _apply_local_profile(cmd, profile);


