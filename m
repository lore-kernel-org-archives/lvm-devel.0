From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Nov 2014 08:19:48 +0000 (UTC)
Subject: master - coverity: fix resource leaks
Message-ID: <20141112081948.E650E605B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba2302346433af7150193025aa8a446fa3238445
Commit:        ba2302346433af7150193025aa8a446fa3238445
Parent:        131aaeb6344b17586571f126468b67c960075f50
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 12 09:18:55 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 12 09:19:14 2014 +0100

coverity: fix resource leaks

LVM2.2.02.112/tools/toollib.c:1991: leaked_storage: Variable "iter" going out of scope leaks the storage it points to.
LVM2.2.02.112/lib/filters/filter-usable.c:89: leaked_storage: Variable "f" going out of scope leaks the storage it points to.
LVM2.2.02.112/lib/activate/dev_manager.c:1874: leaked_handle: Handle variable "fd" going out of scope leaks the handle.
---
 lib/activate/dev_manager.c  |    2 ++
 lib/filters/filter-usable.c |    1 +
 tools/toollib.c             |    8 +++++---
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a392387..efaaa65 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1870,6 +1870,8 @@ static int _pool_callback(struct dm_tree_node *node,
 		}
 		/* let's assume there is no problem to read 64 bytes */
 		if (read(fd, buf, sizeof(buf)) < sizeof(buf)) {
+			if (close(fd))
+				log_sys_error("close", argv[args]);
 			log_sys_error("read", argv[args]);
 			return 0;
 		}
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index a6932b0..f34a325 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -86,6 +86,7 @@ struct dev_filter *usable_filter_create(struct dev_types *dt __attribute__((unus
 	f->use_count = 0;
 	if (!(f->private = dm_zalloc(sizeof(filter_mode_t)))) {
 		log_error("Usable device filter mode allocation failed");
+		dm_free(f);
 		return NULL;
 	}
 	*((filter_mode_t *) f->private) = mode;
diff --git a/tools/toollib.c b/tools/toollib.c
index 596dba5..e47213d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1977,6 +1977,7 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 	struct dev_iter *iter;
 	struct device *dev;
 	struct device_list *devl;
+	int r = ECMD_FAILED;
 
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
@@ -1988,16 +1989,17 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 	while ((dev = dev_iter_get(iter))) {
 		if (!(devl = dm_pool_alloc(cmd->mem, sizeof(*devl)))) {
 			log_error("device_list alloc failed");
-			return ECMD_FAILED;
+			goto out;
 		}
 
 		devl->dev = dev;
 		dm_list_add(all_devices, &devl->list);
 	}
 
+	r = ECMD_PROCESSED;
+out:
 	dev_iter_destroy(iter);
-
-	return ECMD_PROCESSED;
+	return r;
 }
 
 static int _device_list_remove(struct dm_list *all_devices, struct device *dev)


