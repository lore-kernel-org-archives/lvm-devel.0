From: David Teigland <teigland@sourceware.org>
Date: Mon, 16 Aug 2021 16:31:34 +0000 (GMT)
Subject: main - cov: lvmlockd: rewrite string copies to avoid warnings
Message-ID: <20210816163134.59AE7385742B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0d572d14ad14afad43a8a3f5fe033ed3996c05c6
Commit:        0d572d14ad14afad43a8a3f5fe033ed3996c05c6
Parent:        47bcb446b83f9aa4fca74301fda109a8bf670fbb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 2 17:22:45 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 16 11:31:09 2021 -0500

cov: lvmlockd: rewrite string copies to avoid warnings

- Use a new function for all instances of copying
  a null-terminated string into a fixed size struct
  field that is not null-terminated.

- use memcpy when copying between struct fields of
  the same size
---
 daemons/lvmlockd/lvmlockd-sanlock.c | 76 ++++++++++++++++++++++---------------
 1 file changed, 45 insertions(+), 31 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 36d57767f..b351b1d44 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -227,6 +227,20 @@ int lm_data_size_sanlock(void)
 
 static uint64_t daemon_test_lv_count;
 
+/*
+ * Copy a null-terminated string "str" into a fixed
+ * size (SANLK_NAME_LEN) struct field "buf" which is
+ * not null terminated.
+ */
+static void strcpy_name_len(char *buf, char *str, int len)
+{
+	char tmp_name[SANLK_NAME_LEN + 1] = { 0 };
+
+	strncpy(tmp_name, str, SANLK_NAME_LEN);
+
+	memcpy(buf, str, SANLK_NAME_LEN);
+}
+
 static int lock_lv_name_from_args(char *vg_args, char *lock_lv_name)
 {
 	return last_string_from_args(vg_args, lock_lv_name);
@@ -574,7 +588,7 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 		}
 	}
 
-	strncpy(ss.name, ls_name, SANLK_NAME_LEN);
+	strcpy_name_len(ss.name, ls_name, SANLK_NAME_LEN);
 	memcpy(ss.host_id_disk.path, disk.path, SANLK_PATH_LEN);
 	ss.host_id_disk.offset = 0;
 	ss.flags = (sector_size == 4096) ? (SANLK_LSF_SECTOR4K | SANLK_LSF_ALIGN8M) :
@@ -607,7 +621,7 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 		gl_name = R_NAME_GL;
 
 	memcpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
-	strncpy(rd.rs.name, gl_name, SANLK_NAME_LEN);
+	strcpy_name_len(rd.rs.name, (char *)gl_name, SANLK_NAME_LEN);
 	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
 	rd.rs.disks[0].offset = align_size * GL_LOCK_BEGIN;
 	rd.rs.num_disks = 1;
@@ -622,7 +636,7 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	}
 
 	memcpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
-	strncpy(rd.rs.name, R_NAME_VG, SANLK_NAME_LEN);
+	strcpy_name_len(rd.rs.name, (char *)R_NAME_VG, SANLK_NAME_LEN);
 	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
 	rd.rs.disks[0].offset = align_size * VG_LOCK_BEGIN;
 	rd.rs.num_disks = 1;
@@ -656,8 +670,8 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	rd.rs.flags = (sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
 					      (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
-	strncpy(rd.rs.lockspace_name, ls_name, SANLK_NAME_LEN);
-	strcpy(rd.rs.name, "#unused");
+	strcpy_name_len(rd.rs.lockspace_name, ls_name, SANLK_NAME_LEN);
+	strcpy_name_len(rd.rs.name, (char *)"#unused", SANLK_NAME_LEN);
 
 	offset = align_size * LV_LOCK_BEGIN;
 
@@ -725,7 +739,7 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 		return 0;
 	}
 
-	strncpy(rd.rs.lockspace_name, ls_name, SANLK_NAME_LEN);
+	strcpy_name_len(rd.rs.lockspace_name, ls_name, SANLK_NAME_LEN);
 	rd.rs.num_disks = 1;
 	if ((rv = build_dm_path(rd.rs.disks[0].path, SANLK_PATH_LEN, vg_name, lock_lv_name)))
 		return rv;
@@ -800,7 +814,7 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 			log_debug("S %s init_lv_san %s found unused area at %llu",
 				  ls_name, lv_name, (unsigned long long)offset);
 
-			strncpy(rd.rs.name, lv_name, SANLK_NAME_LEN);
+			strcpy_name_len(rd.rs.name, lv_name, SANLK_NAME_LEN);
 			rd.rs.flags = (sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
 							      (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 
@@ -899,7 +913,7 @@ int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_
 	if (!sector_size || !align_size)
 		return -1;
 
-	strncpy(ss.name, ls_name, SANLK_NAME_LEN);
+	strcpy_name_len(ss.name, ls_name, SANLK_NAME_LEN);
 
 	rv = sanlock_write_lockspace(&ss, 0, 0, sanlock_io_timeout);
 	if (rv < 0) {
@@ -924,7 +938,7 @@ int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_
 		return rv;
 	}
 
-	strncpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
+	memcpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
 
 	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
 	if (rv < 0) {
@@ -949,7 +963,7 @@ int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_
 		return rv;
 	}
 
-	strncpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
+	memcpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
 
 	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
 	if (rv < 0) {
@@ -983,7 +997,7 @@ int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_
 			break;
 		}
 
-		strncpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
+		memcpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
 
 		rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
 		if (rv) {
@@ -1009,7 +1023,7 @@ int lm_free_lv_sanlock(struct lockspace *ls, struct resource *r)
 	if (daemon_test)
 		return 0;
 
-	strcpy(rs->name, "#unused");
+	strcpy_name_len(rs->name, (char *)"#unused", SANLK_NAME_LEN);
 
 	rv = sanlock_write_resource(rs, 0, 0, 0);
 	if (rv < 0) {
@@ -1043,14 +1057,14 @@ int lm_ex_disable_gl_sanlock(struct lockspace *ls)
 	memset(&rd1, 0, sizeof(rd1));
 	memset(&rd2, 0, sizeof(rd2));
 
-	strncpy(rd1.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
-	strncpy(rd1.rs.name, R_NAME_GL, SANLK_NAME_LEN);
+	strcpy_name_len(rd1.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	strcpy_name_len(rd1.rs.name, (char *)R_NAME_GL, SANLK_NAME_LEN);
 
-	strncpy(rd2.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
-	strncpy(rd2.rs.name, R_NAME_GL_DISABLED, SANLK_NAME_LEN);
+	strcpy_name_len(rd2.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	strcpy_name_len(rd2.rs.name, (char *)R_NAME_GL_DISABLED, SANLK_NAME_LEN);
 
 	rd1.rs.num_disks = 1;
-	strncpy(rd1.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
+	memcpy(rd1.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 	rd1.rs.disks[0].offset = lms->align_size * GL_LOCK_BEGIN;
 	
 	rd1.rs.flags = (lms->sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
@@ -1112,11 +1126,11 @@ int lm_able_gl_sanlock(struct lockspace *ls, int enable)
 
 	memset(&rd, 0, sizeof(rd));
 
-	strncpy(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
-	strncpy(rd.rs.name, gl_name, SANLK_NAME_LEN);
+	strcpy_name_len(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	strcpy_name_len(rd.rs.name, (char *)gl_name, SANLK_NAME_LEN);
 
 	rd.rs.num_disks = 1;
-	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
+	memcpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 	rd.rs.disks[0].offset = lms->align_size * GL_LOCK_BEGIN;
 	rd.rs.flags = (lms->sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
 						   (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
@@ -1153,12 +1167,12 @@ static int gl_is_enabled(struct lockspace *ls, struct lm_sanlock *lms)
 
 	memset(&rd, 0, sizeof(rd));
 
-	strncpy(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	strcpy_name_len(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
 
 	/* leave rs.name empty, it is what we're checking */
 
 	rd.rs.num_disks = 1;
-	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
+	memcpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 
 	offset = lms->align_size * GL_LOCK_BEGIN;
 	rd.rs.disks[0].offset = offset;
@@ -1224,9 +1238,9 @@ int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset, int *
 
 	memset(&rd, 0, sizeof(rd));
 
-	strncpy(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	strcpy_name_len(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
 	rd.rs.num_disks = 1;
-	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
+	memcpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN-1);
 	rd.rs.flags = (lms->sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) :
 						   (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
 
@@ -1411,7 +1425,7 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 	memcpy(lms->ss.name, lsname, SANLK_NAME_LEN);
 	lms->ss.host_id_disk.offset = 0;
 	lms->ss.host_id = ls->host_id;
-	strncpy(lms->ss.host_id_disk.path, disk_path, SANLK_PATH_LEN-1);
+	memcpy(lms->ss.host_id_disk.path, disk_path, SANLK_PATH_LEN-1);
 
 	if (daemon_test) {
 		if (!gl_lsname_sanlock[0]) {
@@ -1577,7 +1591,7 @@ int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg)
 		 * This shouldn't be generally necessary, but there may some races
 		 * between nodes starting and removing a vg which this could help.
 		 */
-		strncpy(lms->ss.name, "#unused", SANLK_NAME_LEN);
+		strcpy_name_len(lms->ss.name, (char *)"#unused", SANLK_NAME_LEN);
 
 		rv = sanlock_write_lockspace(&lms->ss, 0, 0, sanlock_io_timeout);
 		if (rv < 0) {
@@ -1605,8 +1619,8 @@ static int lm_add_resource_sanlock(struct lockspace *ls, struct resource *r)
 	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
 	struct rd_sanlock *rds = (struct rd_sanlock *)r->lm_data;
 
-	strncpy(rds->rs.lockspace_name, ls->name, SANLK_NAME_LEN);
-	strncpy(rds->rs.name, r->name, SANLK_NAME_LEN);
+	strcpy_name_len(rds->rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	strcpy_name_len(rds->rs.name, r->name, SANLK_NAME_LEN);
 	rds->rs.num_disks = 1;
 	memcpy(rds->rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
 	rds->rs.flags = (lms->sector_size == 4096) ? (SANLK_RES_SECTOR4K | SANLK_RES_ALIGN8M) : (SANLK_RES_SECTOR512 | SANLK_RES_ALIGN1M);
@@ -2035,7 +2049,7 @@ static int release_rename(struct lockspace *ls, struct resource *r)
 	res1 = (struct sanlk_resource *)&rd1;
 	res2 = (struct sanlk_resource *)&rd2;
 
-	strcpy(res2->name, "invalid_removed");
+	strcpy_name_len(res2->name, (char *)"invalid_removed", SANLK_NAME_LEN);
 
 	res_args[0] = res1;
 	res_args[1] = res2;
@@ -2228,8 +2242,8 @@ int lm_get_lockspaces_sanlock(struct list_head *ls_rejoin)
 
 		ls->lm_type = LD_LM_SANLOCK;
 		ls->host_id = ss->host_id;
-		strncpy(ls->name, ss->name, MAX_NAME);
-		strncpy(ls->vg_name, ss->name + strlen(LVM_LS_PREFIX), MAX_NAME);
+		memcpy(ls->name, ss->name, SANLK_NAME_LEN);
+		memcpy(ls->vg_name, ss->name + strlen(LVM_LS_PREFIX), SANLK_NAME_LEN - strlen(LVM_LS_PREFIX));
 		list_add_tail(&ls->list, ls_rejoin);
 
 		ss++;


