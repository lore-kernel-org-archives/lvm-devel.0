From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 15 Jul 2015 08:55:12 +0000 (UTC)
Subject: master - config: use find_config_tree_array for all arrays
Message-ID: <20150715085512.709D9602E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34a410994674f450564d6f221ff5ef0b16d37280
Commit:        34a410994674f450564d6f221ff5ef0b16d37280
Parent:        7e728fe1a164cc5d4f64e46fcfcbb224c22b2457
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 15 10:52:23 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 15 10:52:23 2015 +0200

config: use find_config_tree_array for all arrays

Use find_config_tree_array for all config arrays. Also, add
INTERNAL_ERROR in case there should have been at least default
value defined for a setting but it was not returned for some
reason (either config_settings.h misconfiguration or other config
tree error printed by functions called by find_config_tree_array).
---
 lib/commands/toolcontext.c |   16 ++++++++--------
 lib/mm/memlock.c           |    2 +-
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 002627b..3fe2bb2 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -245,8 +245,10 @@ static int _parse_debug_classes(struct cmd_context *cmd)
 	const struct dm_config_value *cv;
 	int debug_classes = 0;
 
-	if (!(cn = find_config_tree_array(cmd, log_debug_classes_CFG, NULL)))
+	if (!(cn = find_config_tree_array(cmd, log_debug_classes_CFG, NULL))) {
+		log_error(INTERNAL_ERROR "Unable to find configuration for log/debug_classes.");
 		return -1;
+	}
 
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
@@ -686,7 +688,7 @@ static int _process_config(struct cmd_context *cmd)
 						      DEFAULT_RUN_DIR "/lvmetad.socket");
 	*/
 	lvmetad_set_socket(lvmetad_socket);
-	cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL);
+	cn = find_config_tree_array(cmd, devices_global_filter_CFG, NULL);
 	lvmetad_set_token(cn ? cn->v : NULL);
 
 	if (find_config_tree_int(cmd, global_locking_type_CFG, NULL) == 3 &&
@@ -1015,11 +1017,9 @@ static int _init_dev_cache(struct cmd_context *cmd)
 
 	init_obtain_device_list_from_udev(device_list_from_udev);
 
-	if (!(cn = find_config_tree_node(cmd, devices_scan_CFG, NULL))) {
-		log_verbose("device/scan not in config file, "
-			    "using defaults.");
-		if (!(cn = find_config_tree_array(cmd, devices_scan_CFG, NULL)))
-			return_0;
+	if (!(cn = find_config_tree_array(cmd, devices_scan_CFG, NULL))) {
+		log_error(INTERNAL_ERROR "Unable to find configuration for devices/scan.");
+		return_0;
 	}
 
 	for (cv = cn->v; cv; cv = cv->next) {
@@ -1232,7 +1232,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	}
 
 	/* filter component 1 */
-	if ((cn = find_config_tree_node(cmd, devices_filter_CFG, NULL))) {
+	if ((cn = find_config_tree_array(cmd, devices_filter_CFG, NULL))) {
 		if (!(filter_components[1] = regex_filter_create(cn->v)))
 			goto_bad;
 		/* we have two filter components - create composite filter */
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 534aab3..60686ea 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -347,7 +347,7 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 	}
 
 	line = _maps_buffer;
-	cn = find_config_tree_node(cmd, activation_mlock_filter_CFG, NULL);
+	cn = find_config_tree_array(cmd, activation_mlock_filter_CFG, NULL);
 
 	while ((line_end = strchr(line, '\n'))) {
 		*line_end = '\0'; /* remove \n */


