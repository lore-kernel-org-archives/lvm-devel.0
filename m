From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:17 +0000 (GMT)
Subject: master - gcc: use apropriate type for reading and printing values
Message-ID: <20200828195917.9CB433949D80@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee0cb17608d2e9f6d92ea339e121713312c3f84f
Commit:        ee0cb17608d2e9f6d92ea339e121713312c3f84f
Parent:        b918afb693a62938e8189a5d07b13df8007ae062
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:35:25 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:03 2020 +0200

gcc: use apropriate type for reading and printing values

---
 device_mapper/ioctl/libdm-iface.c | 2 +-
 device_mapper/libdm-common.c      | 2 +-
 device_mapper/mm/pool.c           | 2 +-
 lib/label/hints.c                 | 2 +-
 lib/label/label.c                 | 2 +-
 lib/metadata/metadata.c           | 8 ++++----
 lib/metadata/vg.c                 | 4 ++--
 lib/mm/memlock.c                  | 2 +-
 libdm/ioctl/libdm-iface.c         | 2 +-
 libdm/libdm-common.c              | 2 +-
 libdm/libdm-stats.c               | 2 +-
 libdm/mm/pool.c                   | 2 +-
 12 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 25e7d1a75..8e7240673 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -205,7 +205,7 @@ static int _get_proc_number(const char *file, const char *name,
 	}
 
 	while (getline(&line, &len, fl) != -1) {
-		if (sscanf(line, "%d %255s\n", &num, &nm[0]) == 2) {
+		if (sscanf(line, "%u %255s\n", &num, &nm[0]) == 2) {
 			if (!strcmp(name, nm)) {
 				if (number) {
 					*number = num;
diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index bc691d629..b6d08f557 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -512,7 +512,7 @@ int unmangle_string(const char *str, const char *str_name, size_t len,
 	int strict = mode != DM_STRING_MANGLING_NONE;
 	char str_rest[DM_NAME_LEN];
 	size_t i, j;
-	int code;
+	unsigned int code;
 	int r = 0;
 
 	if (!str || !buf)
diff --git a/device_mapper/mm/pool.c b/device_mapper/mm/pool.c
index b6478c54b..18df7ca1e 100644
--- a/device_mapper/mm/pool.c
+++ b/device_mapper/mm/pool.c
@@ -98,7 +98,7 @@ void dm_pools_check_leaks(void)
 			  p->orig_pool,
 			  p->name, p->stats.bytes);
 #else
-		log_error(" [%p] %s", p, p->name);
+		log_error(" [%p] %s", (void *)p, p->name);
 #endif
 	}
 	pthread_mutex_unlock(&_dm_pools_mutex);
diff --git a/lib/label/hints.c b/lib/label/hints.c
index efa02f7c5..fdc0bd6c0 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -737,7 +737,7 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 
 		keylen = strlen("scan_lvs:");
 		if (!strncmp(_hint_line, "scan_lvs:", keylen)) {
-			int scan_lvs = 0;
+			unsigned scan_lvs = 0;
 			if ((sscanf(_hint_line + keylen, "%u", &scan_lvs) != 1) ||
 			    scan_lvs != cmd->scan_lvs) {
 				log_debug("ignore hints with different or unreadable scan_lvs");
diff --git a/lib/label/label.c b/lib/label/label.c
index 4d37ceff6..4d369d4f1 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -716,7 +716,7 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 				       dev_name(devl->dev),
 				       (int)MAJOR(devl->dev->dev),
 				       (int)MINOR(devl->dev->dev),
-				       devl->dev->bcache_fd, bb);
+				       devl->dev->bcache_fd, (void *)bb);
 
 			ret = _process_block(cmd, f, devl->dev, bb, 0, 0, &is_lvm_device);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c0d42066d..4777d7923 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5239,9 +5239,9 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		dm_config_destroy(cft);
 	} else {
 		if (vg->vg_precommitted)
-			log_error(INTERNAL_ERROR "vg_read vg %p vg_precommitted %p", vg, vg->vg_precommitted);
+			log_error(INTERNAL_ERROR "vg_read vg %p vg_precommitted %p", (void *)vg, (void *)vg->vg_precommitted);
 		if (vg->vg_committed)
-			log_error(INTERNAL_ERROR "vg_read vg %p vg_committed %p", vg, vg->vg_committed);
+			log_error(INTERNAL_ERROR "vg_read vg %p vg_committed %p", (void *)vg, (void *)vg->vg_committed);
 	}
 out:
 	/* We return with the VG lock held when read is successful. */
@@ -5265,9 +5265,9 @@ bad:
 	 */
 	if (error_vg && vg) {
 		if (vg->vg_precommitted)
-			log_error(INTERNAL_ERROR "vg_read vg %p vg_precommitted %p", vg, vg->vg_precommitted);
+			log_error(INTERNAL_ERROR "vg_read vg %p vg_precommitted %p", (void *)vg, (void *)vg->vg_precommitted);
 		if (vg->vg_committed)
-			log_error(INTERNAL_ERROR "vg_read vg %p vg_committed %p", vg, vg->vg_committed);
+			log_error(INTERNAL_ERROR "vg_read vg %p vg_committed %p", (void *)vg, (void *)vg->vg_committed);
 
 		/* caller must unlock_vg and release_vg */
 		*error_vg = vg;
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index beddf73de..a809115f6 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -61,7 +61,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->removed_historical_lvs);
 	dm_list_init(&vg->removed_pvs);
 
-	log_debug_mem("Allocated VG %s at %p.", vg->name ? : "<no name>", vg);
+	log_debug_mem("Allocated VG %s at %p.", vg->name ? : "<no name>", (void *)vg);
 
 	return vg;
 }
@@ -76,7 +76,7 @@ static void _free_vg(struct volume_group *vg)
 		return;
 	}
 
-	log_debug_mem("Freeing VG %s at %p.", vg->name ? : "<no name>", vg);
+	log_debug_mem("Freeing VG %s at %p.", vg->name ? : "<no name>", (void *)vg);
 
 	dm_hash_destroy(vg->hostnames);
 	dm_pool_destroy(vg->vgmem);
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index aa47d665b..b06bbc82c 100644
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
index 7ad549c91..f4be478da 100644
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
index d75c7046c..466c74bb9 100644
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
index 420e3e181..05971bdad 100644
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
index 26f43a787..f3e1d1a34 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -98,7 +98,7 @@ void dm_pools_check_leaks(void)
 			  p->orig_pool,
 			  p->name, p->stats.bytes);
 #else
-		log_error(" [%p] %s", p, p->name);
+		log_error(" [%p] %s", (void *)p, p->name);
 #endif
 	}
 	pthread_mutex_unlock(&_dm_pools_mutex);


