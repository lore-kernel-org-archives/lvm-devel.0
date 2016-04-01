From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  1 Apr 2016 12:51:19 +0000 (UTC)
Subject: master - refactor: dev-cache: use btree instead of hash table for sysfs-only devices
Message-ID: <20160401125119.99B4860E4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e774d5ae77fb67c7a015d9bb8e4c289dd8fa2e4
Commit:        0e774d5ae77fb67c7a015d9bb8e4c289dd8fa2e4
Parent:        c57798463078325a7b7b1221d154312a20678e93
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 31 15:14:01 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 1 11:42:25 2016 +0200

refactor: dev-cache: use btree instead of hash table for sysfs-only devices

major:minor btree is more convenient and more suitable than dev name
hash table here.
---
 lib/device/dev-cache.c |   25 ++++++++++---------------
 1 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 12d0d56..d99352b 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -40,9 +40,9 @@ struct dir_list {
 static struct {
 	struct dm_pool *mem;
 	struct dm_hash_table *names;
-	struct dm_hash_table *sysfs_only_names; /* see comments in _get_device_for_sysfs_dev_name_using_devno */
 	struct dm_hash_table *vgid_index;
 	struct dm_hash_table *lvid_index;
+	struct btree *sysfs_only_devices; /* see comments in _get_device_for_sysfs_dev_name_using_devno */
 	struct btree *devices;
 	struct dm_regex *preferred_names_matcher;
 	const char *dev_dir;
@@ -463,20 +463,13 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 		 * problem with devtmpfs as there's at least kernel name for device in /dev as soon
 		 * as the sysfs item exists, but we still support environments without devtmpfs or
 		 * where different directory for dev nodes is used (e.g. our test suite). So track
-		 * such devices in _cache.sysfs_only_names hash for the vgid/lvid check to work still.
+		 * such devices in _cache.sysfs_only_devices hash for the vgid/lvid check to work still.
 		 */
-		if (!_cache.sysfs_only_names) {
-			if (!(_cache.sysfs_only_names = dm_hash_create(32))) {
-				log_error("Failed to create hash in dev cache for sysfs-only devices.");
-				return NULL;
-			}
-		}
-
-		if (!(dev = (struct device *) dm_hash_lookup(_cache.sysfs_only_names, devname))) {
+		if (!(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) devno))) {
 			if (!(dev = _dev_create(devno)))
 				return_NULL;
-			if (!dm_hash_insert(_cache.sysfs_only_names, devname, dev)) {
-				log_error("Couldn't add device to sysfs-only hash in dev cache.");
+			if (!btree_insert(_cache.sysfs_only_devices, (uint32_t) devno, dev)) {
+				log_error("Couldn't add device to binary tree of sysfs-only devices in dev cache.");
 				return NULL;
 			}
 		}
@@ -1068,6 +1061,11 @@ int dev_cache_init(struct cmd_context *cmd)
 		goto bad;
 	}
 
+	if (!(_cache.sysfs_only_devices = btree_create(_cache.mem))) {
+		log_error("Couldn't create binary tree for sysfs-only devices in dev cache.");
+		goto bad;
+	}
+
 	if (!(_cache.dev_dir = _strdup(cmd->dev_dir))) {
 		log_error("strdup dev_dir failed.");
 		goto bad;
@@ -1131,9 +1129,6 @@ int dev_cache_exit(void)
 	if (_cache.names)
 		dm_hash_destroy(_cache.names);
 
-	if (_cache.sysfs_only_names)
-		dm_hash_destroy(_cache.sysfs_only_names);
-
 	if (_cache.vgid_index)
 		dm_hash_destroy(_cache.vgid_index);
 


