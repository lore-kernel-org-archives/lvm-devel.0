From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:48 +0000 (GMT)
Subject: stable-2.02 - gcc: use apropriate type for reading and printing values
Message-ID: <20201016191048.42480396EC5D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55a8b1bd37aefb6835d41118cf94f429e7d20519
Commit:        55a8b1bd37aefb6835d41118cf94f429e7d20519
Parent:        d48266b7fba54f7d57f233f51e9f084fbff69956
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:35:25 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:05 2020 +0200

gcc: use apropriate type for reading and printing values

---
 lib/label/label.c         | 2 +-
 lib/metadata/vg.c         | 4 ++--
 lib/mm/memlock.c          | 2 +-
 libdm/ioctl/libdm-iface.c | 2 +-
 libdm/libdm-common.c      | 2 +-
 libdm/libdm-stats.c       | 2 +-
 libdm/mm/pool.c           | 2 +-
 7 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 8a4b66246..37b3d45a6 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -689,7 +689,7 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 				       dev_name(devl->dev),
 				       (int)MAJOR(devl->dev->dev),
 				       (int)MINOR(devl->dev->dev),
-				       devl->dev->bcache_fd, bb);
+				       devl->dev->bcache_fd, (void *)bb);
 
 			ret = _process_block(cmd, f, devl->dev, bb, 0, 0, &is_lvm_device);
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 42801b961..c3823cece 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -64,7 +64,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->removed_historical_lvs);
 	dm_list_init(&vg->removed_pvs);
 
-	log_debug_mem("Allocated VG %s at %p.", vg->name ? : "<no name>", vg);
+	log_debug_mem("Allocated VG %s at %p.", vg->name ? : "<no name>", (void *)vg);
 
 	return vg;
 }
@@ -79,7 +79,7 @@ static void _free_vg(struct volume_group *vg)
 		return;
 	}
 
-	log_debug_mem("Freeing VG %s at %p.", vg->name ? : "<no name>", vg);
+	log_debug_mem("Freeing VG %s at %p.", vg->name ? : "<no name>", (void *)vg);
 
 	dm_hash_destroy(vg->hostnames);
 	dm_pool_destroy(vg->vgmem);
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index c8e6ef16e..6adc9e83c 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -232,7 +232,7 @@ static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
 		      const char *line, size_t *mstats)
 {
 	const struct dm_config_value *cv;
-	long from, to;
+	unsigned long from, to;
 	int pos;
 	unsigned i;
 	char fr, fw, fx, fp;
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 77bdd070f..14186e680 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -204,7 +204,7 @@ static int _get_proc_number(const char *file, const char *name,
 	}
 
 	while (getline(&line, &len, fl) != -1) {
-		if (sscanf(line, "%d %255s\n", &num, &nm[0]) == 2) {
+		if (sscanf(line, "%u %255s\n", &num, &nm[0]) == 2) {
 			if (!strcmp(name, nm)) {
 				if (number) {
 					*number = num;
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 32d052c84..906922426 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -510,7 +510,7 @@ int unmangle_string(const char *str, const char *str_name, size_t len,
 	int strict = mode != DM_STRING_MANGLING_NONE;
 	char str_rest[DM_NAME_LEN];
 	size_t i, j;
-	int code;
+	unsigned int code;
 	int r = 0;
 
 	if (!str || !buf)
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index b4b714d4f..e46250193 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -403,7 +403,7 @@ static int _stats_bound(const struct dm_stats *dms)
 	if (dms->bind_major > 0 || dms->bind_name || dms->bind_uuid)
 		return 1;
 	/* %p format specifier expects a void pointer. */
-	log_error("Stats handle at %p is not bound.", dms);
+	log_error("Stats handle at %p is not bound.", (const void *)dms);
 	return 0;
 }
 
diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index 1321cc7d6..ed71a2fc8 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -96,7 +96,7 @@ void dm_pools_check_leaks(void)
 			  p->orig_pool,
 			  p->name, p->stats.bytes);
 #else
-		log_error(" [%p] %s", p, p->name);
+		log_error(" [%p] %s", (void *)p, p->name);
 #endif
 	}
 	pthread_mutex_unlock(&_dm_pools_mutex);


