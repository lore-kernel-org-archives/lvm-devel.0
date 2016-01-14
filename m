From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 14 Jan 2016 22:01:33 +0000 (UTC)
Subject: master - lvmlockd: fixes for test mode
Message-ID: <20160114220133.5ED9D6031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1752f5c31e8fc1801cbc694939a16f0eb6695bcd
Commit:        1752f5c31e8fc1801cbc694939a16f0eb6695bcd
Parent:        e710bac03d2625a50131ac325ad90f0d4f6f3d51
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 14 15:57:09 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 14 16:01:29 2016 -0600

lvmlockd: fixes for test mode

Get the test mode working (lvmlockd running with no
lock manager).
---
 daemons/lvmlockd/lvmlockd-core.c    |    2 +-
 daemons/lvmlockd/lvmlockd-dlm.c     |   15 ++++++++-
 daemons/lvmlockd/lvmlockd-sanlock.c |   63 ++++++++++++++++++++++++++++-------
 3 files changed, 66 insertions(+), 14 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index c4def0b..093021d 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -6042,7 +6042,7 @@ int main(int argc, char *argv[])
 			else if (lm == LD_LM_SANLOCK && lm_support_sanlock())
 				gl_use_sanlock = 1;
 			else {
-				fprintf(stderr, "invalid gl-type option");
+				fprintf(stderr, "invalid gl-type option\n");
 				exit(EXIT_FAILURE);
 			}
 			break;
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 2cf2c20..280cf2b 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -163,6 +163,9 @@ int lm_prepare_lockspace_dlm(struct lockspace *ls)
 	struct lm_dlm *lmd;
 	int rv;
 
+	if (daemon_test)
+		goto skip_args;
+
 	memset(sys_clustername, 0, sizeof(sys_clustername));
 	memset(arg_clustername, 0, sizeof(arg_clustername));
 
@@ -470,7 +473,11 @@ int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
 	log_debug("S %s R %s lock_dlm", ls->name, r->name);
 
 	if (daemon_test) {
-		memset(vb_out, 0, sizeof(struct val_blk));
+		if (rdd->vb) {
+			vb_out->version = le16_to_cpu(rdd->vb->version);
+			vb_out->flags = le16_to_cpu(rdd->vb->flags);
+			vb_out->r_version = le32_to_cpu(rdd->vb->r_version);
+		}
 		return 0;
 	}
 
@@ -686,6 +693,9 @@ int lm_hosts_dlm(struct lockspace *ls, int notify)
 	DIR *ls_dir;
 	int count = 0;
 
+	if (daemon_test)
+		return 0;
+
 	memset(ls_nodes_path, 0, sizeof(ls_nodes_path));
 	snprintf(ls_nodes_path, PATH_MAX-1, "%s/%s/nodes",
 		 DLM_LOCKSPACES_PATH, ls->name);
@@ -754,6 +764,9 @@ int lm_is_running_dlm(void)
 	char sys_clustername[MAX_ARGS+1];
 	int rv;
 
+	if (daemon_test)
+		return gl_use_dlm;
+
 	memset(sys_clustername, 0, sizeof(sys_clustername));
 
 	rv = read_cluster_name(sys_clustername);
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 3f1f3e9..6f287b9 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -206,6 +206,8 @@ int lm_data_size_sanlock(void)
 #define VG_LOCK_BEGIN UINT64_C(66)
 #define LV_LOCK_BEGIN UINT64_C(67)
 
+static unsigned int daemon_test_lv_count;
+
 static int lock_lv_name_from_args(char *vg_args, char *lock_lv_name)
 {
 	return last_string_from_args(vg_args, lock_lv_name);
@@ -338,6 +340,7 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	if (daemon_test) {
 		if (!gl_lsname_sanlock[0])
 			strncpy(gl_lsname_sanlock, ls_name, MAX_NAME);
+		snprintf(vg_args, MAX_ARGS, "%s:%s", lock_args_version, lock_lv_name);
 		return 0;
 	}
 
@@ -489,6 +492,15 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 	snprintf(lock_args_version, MAX_ARGS, "%u.%u.%u",
 		 LV_LOCK_ARGS_MAJOR, LV_LOCK_ARGS_MINOR, LV_LOCK_ARGS_PATCH);
 
+	if (daemon_test) {
+		align_size = 1048576;
+		snprintf(lv_args, MAX_ARGS, "%s:%llu",
+			 lock_args_version,
+			 (unsigned long long)((align_size * LV_LOCK_BEGIN) + (align_size * daemon_test_lv_count)));
+		daemon_test_lv_count++;
+		return 0;
+	}
+
 	strncpy(rd.rs.lockspace_name, ls_name, SANLK_NAME_LEN);
 	rd.rs.num_disks = 1;
 	snprintf(rd.rs.disks[0].path, SANLK_PATH_LEN-1, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
@@ -505,12 +517,6 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 		offset = align_size * LV_LOCK_BEGIN;
 	rd.rs.disks[0].offset = offset;
 
-	if (daemon_test) {
-		snprintf(lv_args, MAX_ARGS, "%s:%llu",
-			 lock_args_version, (unsigned long long)1111);
-		return 0;
-	}
-
 	while (1) {
 		rd.rs.disks[0].offset = offset;
 
@@ -759,6 +765,9 @@ int lm_ex_disable_gl_sanlock(struct lockspace *ls)
 	struct sanlk_resource **rs_args;
 	int rv;
 
+	if (daemon_test)
+		return 0;
+
 	rs_args = malloc(2 * sizeof(struct sanlk_resource *));
 	if (!rs_args)
 		return -ENOMEM;
@@ -828,6 +837,9 @@ int lm_able_gl_sanlock(struct lockspace *ls, int enable)
 	else
 		gl_name = R_NAME_GL_DISABLED;
 
+	if (daemon_test)
+		goto out;
+
 	memset(&rd, 0, sizeof(rd));
 
 	strncpy(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
@@ -843,7 +855,7 @@ int lm_able_gl_sanlock(struct lockspace *ls, int enable)
 			  ls->name, enable, rv, rd.rs.disks[0].path);
 		return rv;
 	}
-
+out:
 	log_debug("S %s able_gl %s", ls->name, gl_name);
 
 	ls->sanlock_gl_enabled = enable;
@@ -864,6 +876,9 @@ static int gl_is_enabled(struct lockspace *ls, struct lm_sanlock *lms)
 	uint64_t offset;
 	int rv;
 
+	if (daemon_test)
+		return 1;
+
 	memset(&rd, 0, sizeof(rd));
 
 	strncpy(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
@@ -922,8 +937,10 @@ int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
 	uint64_t offset;
 	int rv;
 
-	if (daemon_test)
+	if (daemon_test) {
+		*free_offset = (1048576 * LV_LOCK_BEGIN) + (1048576 * (daemon_test_lv_count + 1));
 		return 0;
+	}
 
 	memset(&rd, 0, sizeof(rd));
 
@@ -1172,6 +1189,11 @@ int lm_add_lockspace_sanlock(struct lockspace *ls, int adopt)
 	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
 	int rv;
 
+	if (daemon_test) {
+		sleep(2);
+		goto out;
+	}
+
 	rv = sanlock_add_lockspace_timeout(&lms->ss, 0, sanlock_io_timeout);
 	if (rv == -EEXIST && adopt) {
 		/* We could alternatively just skip the sanlock call for adopt. */
@@ -1240,10 +1262,10 @@ int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg)
 				  ls->name, rv, lms->ss.host_id_disk.path);
 		}
 	}
-out:
+
 	if (close(lms->sock))
 		log_error("failed to close sanlock daemon socket connection");
-
+out:
 	free(lms);
 	ls->lm_data = NULL;
 
@@ -1380,7 +1402,11 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 		  (unsigned long long)rs->disks[0].offset);
 
 	if (daemon_test) {
-		memset(vb_out, 0, sizeof(struct val_blk));
+		if (rds->vb) {
+			vb_out->version = le16_to_cpu(rds->vb->version);
+			vb_out->flags = le16_to_cpu(rds->vb->flags);
+			vb_out->r_version = le32_to_cpu(rds->vb->r_version);
+		}
 		return 0;
 	}
 
@@ -1665,8 +1691,15 @@ int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
 	log_debug("S %s R %s unlock_san r_version %u flags %x",
 		  ls->name, r->name, r_version, lmu_flags);
 
-	if (daemon_test)
+	if (daemon_test) {
+		if (rds->vb && r_version && (r->mode == LD_LK_EX)) {
+			if (!rds->vb->version)
+				rds->vb->version = cpu_to_le16(VAL_BLK_VERSION);
+			if (r_version)
+				rds->vb->r_version = cpu_to_le32(r_version);
+		}
 		return 0;
+	}
 
 	if (rds->vb && r_version && (r->mode == LD_LK_EX)) {
 		if (!rds->vb->version) {
@@ -1716,6 +1749,9 @@ int lm_hosts_sanlock(struct lockspace *ls, int notify)
 	int found_others = 0;
 	int i, rv;
 
+	if (daemon_test)
+		return 0;
+
 	rv = sanlock_get_hosts(ls->name, 0, &hss, &hss_count, 0);
 	if (rv < 0) {
 		log_error("S %s hosts_san get_hosts error %d", ls->name, rv);
@@ -1815,6 +1851,9 @@ int lm_is_running_sanlock(void)
 	uint32_t daemon_proto;
 	int rv;
 
+	if (daemon_test)
+		return gl_use_sanlock;
+
 	rv = sanlock_version(0, &daemon_version, &daemon_proto);
 	if (rv < 0)
 		return 0;


