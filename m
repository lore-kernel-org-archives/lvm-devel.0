From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Feb 2015 13:44:31 +0000 (UTC)
Subject: master - cleanup: drop unused value assign
Message-ID: <20150219134431.6EBC560057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c184e9d6b4aa74b5fbed0fb8710dc38b38545f9
Commit:        4c184e9d6b4aa74b5fbed0fb8710dc38b38545f9
Parent:        ed420fb6917162ed17af69a9a0ec9ae26e61e209
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 19 14:03:45 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 19 14:43:25 2015 +0100

cleanup: drop unused value assign

Dop unused value assignments.

Unknown is detected via other combination
(!linear && !striped).

Also change the log_error() message into a warning,
since the function is not really returning error,
but still keep the INTERNAL_ERROR.

Ret value is always set later.
---
 lib/device/dev-type.c   |    5 ++---
 lib/metadata/lv_manip.c |   11 +++++------
 libdm/libdm-config.c    |    4 ++--
 tools/lvconvert.c       |    2 +-
 tools/pvchange.c        |    3 +--
 tools/pvresize.c        |    2 +-
 6 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 1649a3a..882c08d 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -332,16 +332,15 @@ static int _has_partition_table(struct device *dev)
 #ifdef UDEV_SYNC_SUPPORT
 static int _udev_dev_is_partitioned(struct device *dev)
 {
-	const char *value;
 	struct dev_ext *ext;
 
 	if (!(ext = dev_ext_get(dev)))
 		return_0;
 
-	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_PART_TABLE_TYPE)))
+	if (!udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_PART_TABLE_TYPE))
 		return 0;
 
-	if ((value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_PART_ENTRY_DISK)))
+	if (udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_PART_ENTRY_DISK))
 		return 0;
 
 	return 1;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index bdb2ef2..088daaf 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -452,7 +452,7 @@ bad:
 
 int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 		       struct dm_list **layout, struct dm_list **role) {
-	int linear, striped, unknown;
+	int linear, striped;
 	struct lv_segment *seg;
 	int public_lv = 1;
 
@@ -505,7 +505,7 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 	 * linear or striped or mixture of these two.
 	 */
 	if (dm_list_empty(*layout)) {
-		linear = striped = unknown = 0;
+		linear = striped = 0;
 		dm_list_iterate_items(seg, &lv->segments) {
 			if (seg_is_linear(seg))
 				linear = 1;
@@ -519,10 +519,9 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 				 * the role above and we need add proper
 				 * detection for such role!
 				 */
-				unknown = 1;
-				log_error(INTERNAL_ERROR "Failed to properly detect "
-					  "layout and role for LV %s/%s",
-					  lv->vg->name, lv->name);
+				log_warn(INTERNAL_ERROR "WARNING: Failed to properly detect "
+					 "layout and role for LV %s/%s.",
+					 lv->vg->name, lv->name);
 			}
 		}
 
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 1ec604f..f7b07a5 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -522,7 +522,7 @@ static struct dm_config_node *_section(struct parser *p, struct dm_config_node *
 {
 	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
 
-	struct dm_config_node *root, *n;
+	struct dm_config_node *root;
 	struct dm_config_value *value;
 	char *str;
 
@@ -555,7 +555,7 @@ static struct dm_config_node *_section(struct parser *p, struct dm_config_node *
 	if (p->t == TOK_SECTION_B) {
 		match(TOK_SECTION_B);
 		while (p->t != TOK_SECTION_E) {
-			if (!(n = _section(p, root)))
+			if (!(_section(p, root)))
 				return_NULL;
 		}
 		match(TOK_SECTION_E);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 935cbf9..9ec0b0b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3538,7 +3538,7 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 
 int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 {
-	int ret = ECMD_PROCESSED;
+	int ret;
 	struct lvconvert_params lp = {
 		.target_attr = ~0,
 	};
diff --git a/tools/pvchange.c b/tools/pvchange.c
index c3e9215..3eb9e96 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -160,8 +160,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvchange_params params = { 0 };
 	struct processing_handle *handle = NULL;
-
-	int ret = ECMD_PROCESSED;
+	int ret;
 
 	if (!(arg_count(cmd, allocatable_ARG) + arg_is_set(cmd, addtag_ARG) +
 	    arg_is_set(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 0f992a2..3057a7f 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -48,7 +48,7 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvresize_params params;
 	struct processing_handle *handle = NULL;
-	int ret = ECMD_PROCESSED;
+	int ret;
 
 	if (!argc) {
 		log_error("Please supply physical volume(s)");


