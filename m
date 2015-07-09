From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  9 Jul 2015 16:32:22 +0000 (UTC)
Subject: master - coverity: cleanup related to lvmlockd
Message-ID: <20150709163222.CE4F560E3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6294509cc6a6a4f6150e6f4de84483a7f54ad9b5
Commit:        6294509cc6a6a4f6150e6f4de84483a7f54ad9b5
Parent:        14811250420630d9f2f5f9aa3de7e8893b53e53b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 9 11:28:59 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 9 11:29:28 2015 -0500

coverity: cleanup related to lvmlockd

A couple missing mutex unlock on error bugs.
A bunch of buffer size/termination warnings.
---
 daemons/lvmlockd/lvmlockd-core.c     |   12 +++++++-----
 daemons/lvmlockd/lvmlockd-dlm.c      |   12 ++++++------
 daemons/lvmlockd/lvmlockd-internal.h |    8 ++++----
 daemons/lvmlockd/lvmlockd-sanlock.c  |   32 ++++++++++++++++----------------
 4 files changed, 33 insertions(+), 31 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index fee0b88..19d96f0 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -647,6 +647,7 @@ static int add_pollfd(int fd)
 	tmp_pollfd = realloc(pollfd, new_size * sizeof(struct pollfd));
 	if (!tmp_pollfd) {
 		log_error("can't alloc new size %d for pollfd", new_size);
+		pthread_mutex_unlock(&pollfd_mutex);
 		return -ENOMEM;
 	}
 	pollfd = tmp_pollfd;
@@ -2994,15 +2995,15 @@ static int work_init_lv(struct action *act)
 {
 	struct lockspace *ls;
 	char ls_name[MAX_NAME+1];
-	char vg_args[MAX_ARGS];
-	char lv_args[MAX_ARGS];
+	char vg_args[MAX_ARGS+1];
+	char lv_args[MAX_ARGS+1];
 	uint64_t free_offset = 0;
 	int lm_type = 0;
 	int rv = 0;
 
 	memset(ls_name, 0, sizeof(ls_name));
-	memset(vg_args, 0, MAX_ARGS);
-	memset(lv_args, 0, MAX_ARGS);
+	memset(vg_args, 0, sizeof(vg_args));
+	memset(lv_args, 0, sizeof(lv_args));
 
 	vg_ls_name(act->vg_name, ls_name);
 
@@ -3543,6 +3544,7 @@ static int add_lock_action(struct action *act)
 		/* should not happen */
 		log_error("S %s add_lock_action bad lm_type %d ls %d",
 			  ls_name, act->lm_type, ls->lm_type);
+		pthread_mutex_unlock(&lockspaces_mutex);
 		return -EINVAL;
 	}
 
@@ -4622,7 +4624,7 @@ static char *get_dm_uuid(char *dm_name)
 	}
 
 	memset(_dm_uuid, 0, sizeof(_dm_uuid));
-	strcpy(_dm_uuid, uuid);
+	strncpy(_dm_uuid, uuid, sizeof(_dm_uuid)-1);
 	dm_task_destroy(dmt);
 	return _dm_uuid;
 
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index f41599d..eaa2657 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -112,7 +112,7 @@ static int read_cluster_name(char *clustername)
 		return fd;
 	}
 
-	rv = read(fd, clustername, MAX_ARGS - 1);
+	rv = read(fd, clustername, MAX_ARGS);
 	if (rv < 0) {
 		log_error("read_cluster_name: cluster name read error %d, check dlm_controld", fd);
 		if (close(fd))
@@ -130,8 +130,8 @@ static int read_cluster_name(char *clustername)
 
 int lm_init_vg_dlm(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
 {
-	char clustername[MAX_ARGS];
-	char lock_args_version[MAX_ARGS];
+	char clustername[MAX_ARGS+1];
+	char lock_args_version[MAX_ARGS+1];
 	int rv;
 
 	memset(clustername, 0, sizeof(clustername));
@@ -158,8 +158,8 @@ int lm_init_vg_dlm(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
 
 int lm_prepare_lockspace_dlm(struct lockspace *ls)
 {
-	char sys_clustername[MAX_ARGS];
-	char arg_clustername[MAX_ARGS];
+	char sys_clustername[MAX_ARGS+1];
+	char arg_clustername[MAX_ARGS+1];
 	struct lm_dlm *lmd;
 	int rv;
 
@@ -650,7 +650,7 @@ int lm_get_lockspaces_dlm(struct list_head *ls_rejoin)
 
 int lm_is_running_dlm(void)
 {
-	char sys_clustername[MAX_ARGS];
+	char sys_clustername[MAX_ARGS+1];
 	int rv;
 
 	memset(sys_clustername, 0, sizeof(sys_clustername));
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 9eee14a..e9b6277 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -127,8 +127,8 @@ struct action {
 	char vg_name[MAX_NAME+1];
 	char lv_name[MAX_NAME+1];
 	char lv_uuid[MAX_NAME+1];
-	char vg_args[MAX_ARGS];
-	char lv_args[MAX_ARGS];
+	char vg_args[MAX_ARGS+1];
+	char lv_args[MAX_ARGS+1];
 	char vg_sysid[MAX_NAME+1];
 };
 
@@ -145,7 +145,7 @@ struct resource {
 	struct list_head locks;
 	struct list_head actions;
 	struct val_blk *vb;
-	char lv_args[MAX_ARGS];
+	char lv_args[MAX_ARGS+1];
 	char lm_data[0];		/* lock manager specific data */
 };
 
@@ -164,7 +164,7 @@ struct lockspace {
 	char name[MAX_NAME+1];
 	char vg_name[MAX_NAME+1];
 	char vg_uuid[64];
-	char vg_args[MAX_ARGS];		/* lock manager specific args */
+	char vg_args[MAX_ARGS+1];	/* lock manager specific args */
 	char vg_sysid[MAX_NAME+1];
 	int8_t lm_type;			/* lock manager: LM_DLM, LM_SANLOCK */
 	void *lm_data;
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index e83986b..28dac6b 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -167,7 +167,7 @@ static int lock_lv_name_from_args(char *vg_args, char *lock_lv_name)
 
 static int lock_lv_offset_from_args(char *lv_args, uint64_t *lock_lv_offset)
 {
-	char offset_str[MAX_ARGS];
+	char offset_str[MAX_ARGS+1];
 	int rv;
 
 	memset(offset_str, 0, sizeof(offset_str));
@@ -256,8 +256,8 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	struct sanlk_lockspace ss;
 	struct sanlk_resourced rd;
 	struct sanlk_disk disk;
-	char lock_lv_name[MAX_ARGS];
-	char lock_args_version[MAX_ARGS];
+	char lock_lv_name[MAX_ARGS+1];
+	char lock_args_version[MAX_ARGS+1];
 	const char *gl_name = NULL;
 	uint32_t daemon_version;
 	uint32_t daemon_proto;
@@ -285,7 +285,7 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	if (strlen(lock_lv_name) + strlen(lock_args_version) + 2 > MAX_ARGS)
 		return -EARGS;
 
-	snprintf(disk.path, SANLK_PATH_LEN, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
+	snprintf(disk.path, SANLK_PATH_LEN-1, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
 
 	log_debug("S %s init_vg_san path %s", ls_name, disk.path);
 
@@ -423,8 +423,8 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 		       char *vg_args, char *lv_args, uint64_t free_offset)
 {
 	struct sanlk_resourced rd;
-	char lock_lv_name[MAX_ARGS];
-	char lock_args_version[MAX_ARGS];
+	char lock_lv_name[MAX_ARGS+1];
+	char lock_args_version[MAX_ARGS+1];
 	uint64_t offset;
 	int align_size;
 	int rv;
@@ -445,7 +445,7 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 
 	strncpy(rd.rs.lockspace_name, ls_name, SANLK_NAME_LEN);
 	rd.rs.num_disks = 1;
-	snprintf(rd.rs.disks[0].path, SANLK_PATH_LEN, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
+	snprintf(rd.rs.disks[0].path, SANLK_PATH_LEN-1, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
 
 	align_size = sanlock_align(&rd.rs.disks[0]);
 	if (align_size <= 0) {
@@ -529,7 +529,7 @@ int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_
 	struct sanlk_lockspace ss;
 	struct sanlk_resourced rd;
 	struct sanlk_disk disk;
-	char lock_lv_name[MAX_ARGS];
+	char lock_lv_name[MAX_ARGS+1];
 	uint64_t offset;
 	uint32_t io_timeout;
 	int align_size;
@@ -550,7 +550,7 @@ int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_
 		return rv;
 	}
 
-	snprintf(disk.path, SANLK_PATH_LEN, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
+	snprintf(disk.path, SANLK_PATH_LEN-1, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
 
 	log_debug("S %s rename_vg_san path %s", ls_name, disk.path);
 
@@ -730,7 +730,7 @@ int lm_ex_disable_gl_sanlock(struct lockspace *ls)
 	strncpy(rd2.rs.name, R_NAME_GL_DISABLED, SANLK_NAME_LEN);
 
 	rd1.rs.num_disks = 1;
-	strncpy(rd1.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
+	strncpy(rd1.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 	rd1.rs.disks[0].offset = lms->align_size * GL_LOCK_BEGIN;
 
 	rv = sanlock_acquire(lms->sock, -1, 0, 1, &rs1, NULL);
@@ -788,7 +788,7 @@ int lm_able_gl_sanlock(struct lockspace *ls, int enable)
 	strncpy(rd.rs.name, gl_name, SANLK_NAME_LEN);
 
 	rd.rs.num_disks = 1;
-	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
+	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 	rd.rs.disks[0].offset = lms->align_size * GL_LOCK_BEGIN;
 
 	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
@@ -827,7 +827,7 @@ static int gl_is_enabled(struct lockspace *ls, struct lm_sanlock *lms)
 	/* leave rs.name empty, it is what we're checking */
 
 	rd.rs.num_disks = 1;
-	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
+	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 
 	offset = lms->align_size * GL_LOCK_BEGIN;
 	rd.rs.disks[0].offset = offset;
@@ -885,7 +885,7 @@ int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
 
 	strncpy(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
 	rd.rs.num_disks = 1;
-	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
+	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 
 	offset = lms->align_size * LV_LOCK_BEGIN;
 
@@ -960,7 +960,7 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 {
 	struct stat st;
 	struct lm_sanlock *lms = NULL;
-	char lock_lv_name[MAX_ARGS];
+	char lock_lv_name[MAX_ARGS+1];
 	char lsname[SANLK_NAME_LEN + 1];
 	char disk_path[SANLK_PATH_LEN];
 	int gl_found;
@@ -983,7 +983,7 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 		goto fail;
 	}
 
-	snprintf(disk_path, SANLK_PATH_LEN, "/dev/mapper/%s-%s",
+	snprintf(disk_path, SANLK_PATH_LEN-1, "/dev/mapper/%s-%s",
 		 ls->vg_name, lock_lv_name);
 
 	/*
@@ -1035,7 +1035,7 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 	memcpy(lms->ss.name, lsname, SANLK_NAME_LEN);
 	lms->ss.host_id_disk.offset = 0;
 	lms->ss.host_id = ls->host_id;
-	strncpy(lms->ss.host_id_disk.path, disk_path, SANLK_PATH_LEN);
+	strncpy(lms->ss.host_id_disk.path, disk_path, SANLK_PATH_LEN-1);
 
 	if (daemon_test) {
 		if (!gl_lsname_sanlock[0]) {


