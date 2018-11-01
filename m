From: David Teigland <teigland@sourceware.org>
Date: Thu, 1 Nov 2018 14:26:05 -0400
Subject: master - lvmlockd: use new sanlock sector/align interface
Message-ID: <201811011826.wA1IQ5tV020315@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0b01e3f5d7ce1c954aa9f3707aa645508664f7f1
Commit:        0b01e3f5d7ce1c954aa9f3707aa645508664f7f1
Parent:        925aaf0b874fd92aec1b34f42d23987f65205ff9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 22 15:45:23 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 1 13:25:21 2018 -0500

lvmlockd: use new sanlock sector/align interface

The choice about sector size and lease align size is
now made by the sanlock user, in this case lvmlockd.
This will allow lvmlockd to use other lease sizes in
the future.  This also prevents breakage if hosts
report different sector sizes, or the sector size
reported by a device changes.
---
 daemons/lvmlockd/lvmlockd-core.c     |   21 ++-
 daemons/lvmlockd/lvmlockd-internal.h |    8 +-
 daemons/lvmlockd/lvmlockd-sanlock.c  |  311 ++++++++++++++++++++++++++++++----
 3 files changed, 301 insertions(+), 39 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 6490b40..5bdbefe 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -929,12 +929,12 @@ static void lm_rem_resource(struct lockspace *ls, struct resource *r)
 		lm_rem_resource_sanlock(ls, r);
 }
 
-static int lm_find_free_lock(struct lockspace *ls, uint64_t *free_offset)
+static int lm_find_free_lock(struct lockspace *ls, uint64_t *free_offset, int *sector_size, int *align_size)
 {
 	if (ls->lm_type == LD_LM_DLM)
 		return 0;
 	else if (ls->lm_type == LD_LM_SANLOCK)
-		return lm_find_free_lock_sanlock(ls, free_offset);
+		return lm_find_free_lock_sanlock(ls, free_offset, sector_size, align_size);
 	return -1;
 }
 
@@ -2427,11 +2427,16 @@ static void *lockspace_thread_main(void *arg_in)
 
 			if (act->op == LD_OP_FIND_FREE_LOCK && act->rt == LD_RT_VG) {
 				uint64_t free_offset = 0;
+				int sector_size = 0;
+				int align_size = 0;
+
 				log_debug("S %s find free lock", ls->name);
-				rv = lm_find_free_lock(ls, &free_offset);
-				log_debug("S %s find free lock %d offset %llu",
-					  ls->name, rv, (unsigned long long)free_offset);
+				rv = lm_find_free_lock(ls, &free_offset, &sector_size, &align_size);
+				log_debug("S %s find free lock %d offset %llu sector_size %d align_size %d",
+					  ls->name, rv, (unsigned long long)free_offset, sector_size, align_size);
 				ls->free_lock_offset = free_offset;
+				ls->free_lock_sector_size = sector_size;
+				ls->free_lock_align_size = align_size;
 				list_del(&act->list);
 				act->result = rv;
 				add_client_result(act);
@@ -3237,6 +3242,8 @@ static int work_init_lv(struct action *act)
 	char vg_args[MAX_ARGS+1];
 	char lv_args[MAX_ARGS+1];
 	uint64_t free_offset = 0;
+	int sector_size = 0;
+	int align_size = 0;
 	int lm_type = 0;
 	int rv = 0;
 
@@ -3252,6 +3259,8 @@ static int work_init_lv(struct action *act)
 		lm_type = ls->lm_type;
 		memcpy(vg_args, ls->vg_args, MAX_ARGS);
 		free_offset = ls->free_lock_offset;
+		sector_size = ls->free_lock_sector_size;
+		align_size = ls->free_lock_align_size;
 	}
 	pthread_mutex_unlock(&lockspaces_mutex);
 
@@ -3268,7 +3277,7 @@ static int work_init_lv(struct action *act)
 
 	if (lm_type == LD_LM_SANLOCK) {
 		rv = lm_init_lv_sanlock(ls_name, act->vg_name, act->lv_uuid,
-					vg_args, lv_args, free_offset);
+					vg_args, lv_args, sector_size, align_size, free_offset);
 
 		memcpy(act->lv_args, lv_args, MAX_ARGS);
 		return rv;
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index a2280b8..ead3098 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -174,7 +174,9 @@ struct lockspace {
 	int8_t lm_type;			/* lock manager: LM_DLM, LM_SANLOCK */
 	void *lm_data;
 	uint64_t host_id;
-	uint64_t free_lock_offset;	/* start search for free lock here */
+	uint64_t free_lock_offset;	/* for sanlock, start search for free lock here */
+	int free_lock_sector_size;	/* for sanlock */
+	int free_lock_align_size;	/* for sanlock */
 
 	uint32_t start_client_id;	/* client_id that started the lockspace */
 	pthread_t thread;		/* makes synchronous lock requests */
@@ -468,7 +470,7 @@ static inline int lm_hosts_dlm(struct lockspace *ls, int notify)
 #ifdef LOCKDSANLOCK_SUPPORT
 
 int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
-int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, uint64_t free_offset);
+int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, int sector_size, int align_size, uint64_t free_offset);
 int lm_free_lv_sanlock(struct lockspace *ls, struct resource *r);
 int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
 int lm_prepare_lockspace_sanlock(struct lockspace *ls);
@@ -488,7 +490,7 @@ int lm_gl_is_enabled(struct lockspace *ls);
 int lm_get_lockspaces_sanlock(struct list_head *ls_rejoin);
 int lm_data_size_sanlock(void);
 int lm_is_running_sanlock(void);
-int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset);
+int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset, int *sector_size, int *align_size);
 
 static inline int lm_support_sanlock(void)
 {
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index d5d6864..892b446 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -24,10 +24,29 @@
 #include "sanlock_admin.h"
 #include "sanlock_resource.h"
 
+/* FIXME: these are copied from sanlock.h only until
+   an updated version of sanlock is available with them. */
+#define SANLK_RES_ALIGN1M       0x00000010
+#define SANLK_RES_ALIGN2M       0x00000020
+#define SANLK_RES_ALIGN4M       0x00000040
+#define SANLK_RES_ALIGN8M       0x00000080
+#define SANLK_RES_SECTOR512     0x00000100
+#define SANLK_RES_SECTOR4K      0x00000200
+#define SANLK_LSF_ALIGN1M       0x00000010
+#define SANLK_LSF_ALIGN2M       0x00000020
+#define SANLK_LSF_ALIGN4M       0x00000040
+#define SANLK_LSF_ALIGN8M       0x00000080
+#define SANLK_LSF_SECTOR512     0x00000100
+#define SANLK_LSF_SECTOR4K      0x00000200
+
 #include <stddef.h>
 #include <poll.h>
 #include <errno.h>
 #include <syslog.h>
+#include <blkid/blkid.h>
+#include <linux/kdev_t.h>
+
+#define ONE_MB 1048576
 
 /*
 -------------------------------------------------------------------------------
@@ -139,6 +158,7 @@ release all the leases for the VG.
 
 struct lm_sanlock {
 	struct sanlk_lockspace ss;
+	int sector_size;
 	int align_size;
 	int sock; /* sanlock daemon connection */
 };
@@ -201,7 +221,6 @@ int lm_data_size_sanlock(void)
  * ...
  */
 
-#define LS_BEGIN 0
 #define GL_LOCK_BEGIN UINT64_C(65)
 #define VG_LOCK_BEGIN UINT64_C(66)
 #define LV_LOCK_BEGIN UINT64_C(67)
@@ -324,6 +343,152 @@ fail:
 	return rv;
 }
 
+static void _read_sysfs_size(dev_t devno, const char *name, unsigned int *val)
+{
+	char path[PATH_MAX];
+	char buf[32];
+	FILE *fp;
+	size_t len;
+
+	snprintf(path, sizeof(path), "/sys/dev/block/%d:%d/queue/%s",
+		 (int)MAJOR(devno), (int)MINOR(devno), name);
+
+	if (!(fp = fopen(path, "r")))
+		return;
+
+	if (!fgets(buf, sizeof(buf), fp))
+		goto out;
+
+	if ((len = strlen(buf)) && buf[len - 1] == '\n')
+		buf[--len] = '\0';
+
+	if (strlen(buf))
+		*val = atoi(buf);
+out:
+	fclose(fp);
+}
+
+/* Select sector/align size for a new VG based on what the device reports for
+   sector size of the lvmlock LV. */
+
+static int get_sizes_device(char *path, int *sector_size, int *align_size)
+{
+	unsigned int physical_block_size = 0;
+	unsigned int logical_block_size = 0;
+	struct stat st;
+	int rv;
+
+	rv = stat(path, &st);
+	if (rv < 0) {
+		log_error("Failed to stat device to get block size %s %d", path, errno);
+		return -1;
+	}
+
+	_read_sysfs_size(st.st_rdev, "physical_block_size", &physical_block_size);
+	_read_sysfs_size(st.st_rdev, "logical_block_size", &logical_block_size);
+
+	if ((physical_block_size == 512) && (logical_block_size == 512)) {
+		*sector_size = 512;
+		*align_size = ONE_MB;
+		return 0;
+	}
+
+	if ((physical_block_size == 4096) && (logical_block_size == 4096)) {
+		*sector_size = 4096;
+		*align_size = 8 * ONE_MB;
+		return 0;
+	}
+
+	if (physical_block_size && (physical_block_size != 512) && (physical_block_size != 4096)) {
+		log_warn("WARNING: invalid block sizes physical %u logical %u for %s",
+			 physical_block_size, logical_block_size, path);
+		physical_block_size = 0;
+	}
+
+	if (logical_block_size && (logical_block_size != 512) && (logical_block_size != 4096)) {
+		log_warn("WARNING: invalid block sizes physical %u logical %u for %s",
+			 physical_block_size, logical_block_size, path);
+		logical_block_size = 0;
+	}
+
+	if (!physical_block_size && !logical_block_size) {
+		log_error("Failed to get a block size for %s", path);
+		return -1;
+	}
+
+	if (!physical_block_size || !logical_block_size) {
+		log_warn("WARNING: incomplete block size information physical %u logical %u for %s",
+			 physical_block_size, logical_block_size, path);
+		if (!physical_block_size)
+			physical_block_size = logical_block_size;
+		if (!logical_block_size)
+			logical_block_size = physical_block_size;
+	}
+
+	if ((logical_block_size == 4096) && (physical_block_size == 512)) {
+		log_warn("WARNING: mixed block sizes physical %u logical %u (using 4096) for %s",
+			 physical_block_size, logical_block_size, path);
+		*sector_size = 4096;
+		*align_size = 8 * ONE_MB;
+		return 0;
+	}
+
+	if ((physical_block_size == 4096) && (logical_block_size == 512)) {
+		log_warn("WARNING: mixed block sizes physical %u logical %u (using 4096) for %s",
+			 physical_block_size, logical_block_size, path);
+		*sector_size = 4096;
+		*align_size = 8 * ONE_MB;
+		return 0;
+	}
+
+	if (physical_block_size == 512) {
+		*sector_size = 512;
+		*align_size = ONE_MB;
+		return 0;
+	}
+
+	if (physical_block_size == 4096) {
+		*sector_size = 4096;
+		*align_size = 8 * ONE_MB;
+		return 0;
+	}
+
+	log_error("Failed to get a block size for %s", path);
+	return -1;
+}
+
+
+/* Get the sector/align sizes that were used to create an existing VG.
+   sanlock encoded this in the lockspace/resource structs on disk. */
+
+static int get_sizes_lockspace(char *path, int *sector_size, int *align_size)
+{
+	struct sanlk_lockspace ss;
+	uint32_t io_timeout = 0;
+	int rv;
+
+	memset(&ss, 0, sizeof(ss));
+	memcpy(ss.host_id_disk.path, path, SANLK_PATH_LEN);
+	ss.host_id_disk.offset = 0;
+
+	rv = sanlock_read_lockspace(&ss, 0, &io_timeout);
+	if (rv < 0) {
+		log_error("get_sizes_lockspace %s error %d", path, rv);
+		return rv;
+	}
+
+	if ((ss.flags & SANLK_LSF_SECTOR4K) && (ss.flags & SANLK_LSF_ALIGN8M)) {
+		*sector_size = 4096;
+		*align_size = 8 * ONE_MB;
+	} else if ((ss.flags & SANLK_LSF_SECTOR512) && (ss.flags & SANLK_LSF_ALIGN1M)) {
+		*sector_size = 512;
+		*align_size = ONE_MB;
+	}
+
+	log_debug("get_sizes_lockspace found %d %d", *sector_size, *align_size);
+	return 0;
+}
+
 /*
  * vgcreate
  *
@@ -343,7 +508,8 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	uint32_t daemon_version;
 	uint32_t daemon_proto;
 	uint64_t offset;
-	int align_size;
+	int sector_size = 0;
+	int align_size = 0;
 	int i, rv;
 
 	memset(&ss, 0, sizeof(ss));
@@ -387,23 +553,25 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	log_debug("sanlock daemon version %08x proto %08x",
 		  daemon_version, daemon_proto);
 
-	rv = sanlock_align(&disk);
-	if (rv <= 0) {
+	/* Nothing formatted on disk yet, use what the device reports. */
+	rv = get_sizes_device(disk.path, &sector_size, &align_size);
+	if (rv < 0) {
 		if (rv == -EACCES) {
 			log_error("S %s init_vg_san sanlock error -EACCES: no permission to access %s",
 				  ls_name, disk.path);
 			return -EDEVOPEN;
 		} else {
-			log_error("S %s init_vg_san sanlock error %d trying to get align size of %s",
+			log_error("S %s init_vg_san sanlock error %d trying to get sector/align size of %s",
 				  ls_name, rv, disk.path);
 			return -EARGS;
 		}
-	} else
-		align_size = rv;
+	}
 
 	strncpy(ss.name, ls_name, SANLK_NAME_LEN);
 	memcpy(ss.host_id_disk.path, disk.path, SANLK_PATH_LEN);
-	ss.host_id_disk.offset = LS_BEGIN * align_size;
+	ss.host_id_disk.offset = 0;
+	ss.flags = (sector_size == 4096) ? (SANLK_LSF_SECTOR4K | SANLK_LSF_ALIGN8M) :
+					   (SANLK_LSF_SECTOR512 | SANLK_LSF_ALIGN1M);
 
 	rv = sanlock_write_lockspace(&ss, 0, 0, sanlock_io_timeout);
 	if (rv < 0) {
@@ -436,6 +604,8 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
 	rd.rs.disks[0].offset = align_size * GL_LOCK_BEGIN;
 	rd.rs.num_disks = 1;
+	rd.rs.flags = (sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
+					      (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 
 	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
 	if (rv < 0) {
@@ -449,6 +619,8 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
 	rd.rs.disks[0].offset = align_size * VG_LOCK_BEGIN;
 	rd.rs.num_disks = 1;
+	rd.rs.flags = (sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
+					      (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 
 	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
 	if (rv < 0) {
@@ -472,6 +644,8 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 
 	memset(&rd, 0, sizeof(rd));
 	rd.rs.num_disks = 1;
+	rd.rs.flags = (sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
+					      (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
 	strncpy(rd.rs.lockspace_name, ls_name, SANLK_NAME_LEN);
 	strcpy(rd.rs.name, "#unused");
@@ -510,13 +684,13 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
  */
 
 int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
-		       char *vg_args, char *lv_args, uint64_t free_offset)
+		       char *vg_args, char *lv_args,
+		       int sector_size, int align_size, uint64_t free_offset)
 {
 	struct sanlk_resourced rd;
 	char lock_lv_name[MAX_ARGS+1];
 	char lock_args_version[MAX_ARGS+1];
 	uint64_t offset;
-	int align_size;
 	int rv;
 
 	memset(&rd, 0, sizeof(rd));
@@ -534,7 +708,7 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 		 LV_LOCK_ARGS_MAJOR, LV_LOCK_ARGS_MINOR, LV_LOCK_ARGS_PATCH);
 
 	if (daemon_test) {
-		align_size = 1048576;
+		align_size = ONE_MB;
 		snprintf(lv_args, MAX_ARGS, "%s:%llu",
 			 lock_args_version,
 			 (unsigned long long)((align_size * LV_LOCK_BEGIN) + (align_size * daemon_test_lv_count)));
@@ -547,12 +721,35 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 	if ((rv = build_dm_path(rd.rs.disks[0].path, SANLK_PATH_LEN, vg_name, lock_lv_name)))
 		return rv;
 
-	align_size = sanlock_align(&rd.rs.disks[0]);
-	if (align_size <= 0) {
-		log_error("S %s init_lv_san align error %d", ls_name, align_size);
-		return -EINVAL;
+	/*
+	 * These should not usually be zero, maybe only the first time this function is called?
+	 * We need to use the same sector/align sizes that are already being used.
+	 */
+	if (!sector_size || !align_size) {
+		rv = get_sizes_lockspace(rd.rs.disks[0].path, &sector_size, &align_size);
+		if (rv < 0) {
+			log_error("S %s init_lv_san read_lockspace error %d %s",
+				  ls_name, rv, rd.rs.disks[0].path);
+			return rv;
+		}
+
+		if (sector_size)
+			log_debug("S %s init_lv_san found ls sector_size %d align_size %d", ls_name, sector_size, align_size);
+		else {
+			/* use the old method */
+			align_size = sanlock_align(&rd.rs.disks[0]);
+			if (align_size <= 0) {
+				log_error("S %s init_lv_san align error %d", ls_name, align_size);
+				return -EINVAL;
+			}
+			sector_size = (align_size == ONE_MB) ? 512 : 4096;
+			log_debug("S %s init_lv_san found old sector_size %d align_size %d", ls_name, sector_size, align_size);
+		}
 	}
 
+	rd.rs.flags = (sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
+					      (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
+
 	if (free_offset)
 		offset = free_offset;
 	else
@@ -595,6 +792,8 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 				  ls_name, lv_name, (unsigned long long)offset);
 
 			strncpy(rd.rs.name, lv_name, SANLK_NAME_LEN);
+			rd.rs.flags = (sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
+							      (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 
 			rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
 			if (!rv) {
@@ -626,7 +825,8 @@ int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_
 	char lock_lv_name[MAX_ARGS+1];
 	uint64_t offset;
 	uint32_t io_timeout;
-	int align_size;
+	int sector_size = 0;
+	int align_size = 0;
 	int i, rv;
 
 	memset(&disk, 0, sizeof(disk));
@@ -655,20 +855,13 @@ int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_
 	/* FIXME: device is not always ready for us here */
 	sleep(1);
 
-	align_size = sanlock_align(&disk);
-	if (align_size <= 0) {
-		log_error("S %s rename_vg_san bad align size %d %s",
-			  ls_name, align_size, disk.path);
-		return -EINVAL;
-	}
-
 	/*
 	 * Lockspace
 	 */
 
 	memset(&ss, 0, sizeof(ss));
 	memcpy(ss.host_id_disk.path, disk.path, SANLK_PATH_LEN);
-	ss.host_id_disk.offset = LS_BEGIN * align_size;
+	ss.host_id_disk.offset = 0;
 
 	rv = sanlock_read_lockspace(&ss, 0, &io_timeout);
 	if (rv < 0) {
@@ -677,6 +870,26 @@ int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_
 		return rv;
 	}
 
+	if ((ss.flags & SANLK_LSF_SECTOR4K) && (ss.flags & SANLK_LSF_ALIGN8M)) {
+		sector_size = 4096;
+		align_size = 8 * ONE_MB;
+	} else if ((ss.flags & SANLK_LSF_SECTOR512) && (ss.flags & SANLK_LSF_ALIGN1M)) {
+		sector_size = 512;
+		align_size = ONE_MB;
+	} else {
+		/* use the old method */
+		align_size = sanlock_align(&ss.host_id_disk);
+		if (align_size <= 0) {
+			log_error("S %s rename_vg_san unknown sector/align size for %s",
+				 ls_name, ss.host_id_disk.path);
+			return -1;
+		}
+		sector_size = (align_size == ONE_MB) ? 512 : 4096;
+	}
+
+	if (!sector_size || !align_size)
+		return -1;
+
 	strncpy(ss.name, ls_name, SANLK_NAME_LEN);
 
 	rv = sanlock_write_lockspace(&ss, 0, 0, sanlock_io_timeout);
@@ -830,6 +1043,11 @@ int lm_ex_disable_gl_sanlock(struct lockspace *ls)
 	rd1.rs.num_disks = 1;
 	strncpy(rd1.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 	rd1.rs.disks[0].offset = lms->align_size * GL_LOCK_BEGIN;
+	
+	rd1.rs.flags = (lms->sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
+						    (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
+	rd2.rs.flags = (lms->sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
+						    (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 
 	rv = sanlock_acquire(lms->sock, -1, 0, 1, &rs1, NULL);
 	if (rv < 0) {
@@ -891,6 +1109,8 @@ int lm_able_gl_sanlock(struct lockspace *ls, int enable)
 	rd.rs.num_disks = 1;
 	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 	rd.rs.disks[0].offset = lms->align_size * GL_LOCK_BEGIN;
+	rd.rs.flags = (lms->sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
+						   (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 
 	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
 	if (rv < 0) {
@@ -936,7 +1156,8 @@ static int gl_is_enabled(struct lockspace *ls, struct lm_sanlock *lms)
 
 	rv = sanlock_read_resource(&rd.rs, 0);
 	if (rv < 0) {
-		log_error("gl_is_enabled read_resource error %d", rv);
+		log_error("gl_is_enabled read_resource align_size %d offset %llu error %d",
+			  lms->align_size, (unsigned long long)offset, rv);
 		return rv;
 	}
 
@@ -973,7 +1194,7 @@ int lm_gl_is_enabled(struct lockspace *ls)
  * been disabled.)
  */
 
-int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
+int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset, int *sector_size, int *align_size)
 {
 	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
 	struct sanlk_resourced rd;
@@ -983,15 +1204,22 @@ int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
 	int round = 0;
 
 	if (daemon_test) {
-		*free_offset = (1048576 * LV_LOCK_BEGIN) + (1048576 * (daemon_test_lv_count + 1));
+		*free_offset = (ONE_MB * LV_LOCK_BEGIN) + (ONE_MB * (daemon_test_lv_count + 1));
+		*sector_size = 512;
+		*align_size = ONE_MB;
 		return 0;
 	}
 
+	*sector_size = lms->sector_size;
+	*align_size = lms->align_size;
+
 	memset(&rd, 0, sizeof(rd));
 
 	strncpy(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
 	rd.rs.num_disks = 1;
 	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
+	rd.rs.flags = (lms->sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
+						   (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 
 	if (ls->free_lock_offset)
 		offset = ls->free_lock_offset;
@@ -1091,6 +1319,8 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 	char disk_path[SANLK_PATH_LEN];
 	char killpath[SANLK_PATH_LEN];
 	char killargs[SANLK_PATH_LEN];
+	int sector_size = 0;
+	int align_size = 0;
 	int gl_found;
 	int ret, rv;
 
@@ -1207,13 +1437,33 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 		goto fail;
 	}
 
-	lms->align_size = sanlock_align(&lms->ss.host_id_disk);
-	if (lms->align_size <= 0) {
-		log_error("S %s prepare_lockspace_san align error %d", lsname, lms->align_size);
+	rv = get_sizes_lockspace(disk_path, &sector_size, &align_size);
+	if (rv < 0) {
+		log_error("S %s prepare_lockspace_san cannot get sector/align sizes %d", lsname, rv);
 		ret = -EMANAGER;
 		goto fail;
 	}
 
+	if (!sector_size) {
+		log_debug("S %s prepare_lockspace_san using old size method", lsname);
+		/* use the old method */
+		align_size = sanlock_align(&lms->ss.host_id_disk);
+		if (align_size <= 0) {
+			log_error("S %s prepare_lockspace_san align error %d", lsname, align_size);
+			return -EINVAL;
+		}
+		sector_size = (align_size == ONE_MB) ? 512 : 4096;
+		log_debug("S %s prepare_lockspace_san found old sector_size %d align_size %d", lsname, sector_size, align_size);
+	}
+
+	log_debug("S %s prepare_lockspace_san sizes %d %d", lsname, sector_size, align_size);
+
+	lms->align_size = align_size;
+	lms->sector_size = sector_size;
+
+	lms->ss.flags = (sector_size == 4096) ? (SANLK_LSF_SECTOR4K | SANLK_LSF_ALIGN8M) :
+						(SANLK_LSF_SECTOR512 | SANLK_LSF_ALIGN1M);
+
 	gl_found = gl_is_enabled(ls, lms);
 	if (gl_found < 0) {
 		log_error("S %s prepare_lockspace_san gl_enabled error %d", lsname, gl_found);
@@ -1351,6 +1601,7 @@ static int lm_add_resource_sanlock(struct lockspace *ls, struct resource *r)
 	strncpy(rds->rs.name, r->name, SANLK_NAME_LEN);
 	rds->rs.num_disks = 1;
 	memcpy(rds->rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
+	rds->rs.flags = (lms->sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) : (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 
 	if (r->type == LD_RT_GL)
 		rds->rs.disks[0].offset = GL_LOCK_BEGIN * lms->align_size;


