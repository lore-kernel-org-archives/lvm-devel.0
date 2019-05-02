From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 May 2019 14:27:10 -0400
Subject: master - lvmlockd: fix snprintf warnings
Message-ID: <201905021827.x42IRAUg007837@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81735b46d9c7ab8f2dd27835d2a43cc5ad705c86
Commit:        81735b46d9c7ab8f2dd27835d2a43cc5ad705c86
Parent:        0046c4e7a7f647096dc49df29f66bdaba4e11c00
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 2 12:41:00 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 2 12:59:55 2019 -0500

lvmlockd: fix snprintf warnings

---
 daemons/lvmlockd/lvmlockd-core.c    |    8 +++++---
 daemons/lvmlockd/lvmlockd-dlm.c     |   10 +++++++---
 daemons/lvmlockd/lvmlockd-sanlock.c |   18 ++++++++++++------
 3 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index ab413fb..5609ccc 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2230,7 +2230,7 @@ static void *lockspace_thread_main(void *arg_in)
 	struct action *act_op_free = NULL;
 	struct list_head tmp_act;
 	struct list_head act_close;
-	char tmp_name[MAX_NAME+1];
+	char tmp_name[MAX_NAME+5];
 	int free_vg = 0;
 	int drop_vg = 0;
 	int error = 0;
@@ -2624,8 +2624,10 @@ out_act:
 	 * blank or fill it with garbage, but instead set it to REM:<name>
 	 * to make it easier to follow progress of freeing is via log_debug.
 	 */
-	dm_strncpy(tmp_name, ls->name, sizeof(tmp_name));
-	snprintf(ls->name, sizeof(ls->name), "REM:%s", tmp_name);
+	memset(tmp_name, 0, sizeof(tmp_name));
+	memcpy(tmp_name, "REM:", 4);
+	strncpy(tmp_name+4, ls->name, sizeof(tmp_name)-4);
+	memcpy(ls->name, tmp_name, sizeof(ls->name));
 	pthread_mutex_unlock(&lockspaces_mutex);
 
 	/* worker_thread will join this thread, and free the ls */
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index bfc1d23..75e6dee 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -128,16 +128,18 @@ static int read_cluster_name(char *clustername)
 	return 0;
 }
 
+#define MAX_VERSION 16
+
 int lm_init_vg_dlm(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
 {
 	char clustername[MAX_ARGS+1];
-	char lock_args_version[MAX_ARGS+1];
+	char lock_args_version[MAX_VERSION+1];
 	int rv;
 
 	memset(clustername, 0, sizeof(clustername));
 	memset(lock_args_version, 0, sizeof(lock_args_version));
 
-	snprintf(lock_args_version, MAX_ARGS, "%u.%u.%u",
+	snprintf(lock_args_version, MAX_VERSION, "%u.%u.%u",
 		 VG_LOCK_ARGS_MAJOR, VG_LOCK_ARGS_MINOR, VG_LOCK_ARGS_PATCH);
 
 	rv = read_cluster_name(clustername);
@@ -149,7 +151,9 @@ int lm_init_vg_dlm(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
 		return -EARGS;
 	}
 
-	snprintf(vg_args, MAX_ARGS, "%s:%s", lock_args_version, clustername);
+	rv = snprintf(vg_args, MAX_ARGS, "%s:%s", lock_args_version, clustername);
+	if (rv >= MAX_ARGS)
+		log_debug("init_vg_dlm vg_args may be too long %d %s", rv, vg_args);
 	rv = 0;
 
 	log_debug("init_vg_dlm done %s vg_args %s", ls_name, vg_args);
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index f960daf..4bc6402 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -500,13 +500,15 @@ static int get_sizes_lockspace(char *path, int *sector_size, int *align_size)
  * version and lv name, and returns the real lock_args in vg_args.
  */
 
+#define MAX_VERSION 16
+
 int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
 {
 	struct sanlk_lockspace ss;
 	struct sanlk_resourced rd;
 	struct sanlk_disk disk;
 	char lock_lv_name[MAX_ARGS+1];
-	char lock_args_version[MAX_ARGS+1];
+	char lock_args_version[MAX_VERSION+1];
 	const char *gl_name = NULL;
 	uint32_t daemon_version;
 	uint32_t daemon_proto;
@@ -526,7 +528,7 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 		return -EARGS;
 	}
 
-	snprintf(lock_args_version, MAX_ARGS, "%u.%u.%u",
+	snprintf(lock_args_version, MAX_VERSION, "%u.%u.%u",
 		 VG_LOCK_ARGS_MAJOR, VG_LOCK_ARGS_MINOR, VG_LOCK_ARGS_PATCH);
 
 	/* see comment above about input vg_args being only lock_lv_name */
@@ -543,7 +545,9 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	if (daemon_test) {
 		if (!gl_lsname_sanlock[0])
 			strncpy(gl_lsname_sanlock, ls_name, MAX_NAME);
-		snprintf(vg_args, MAX_ARGS, "%s:%s", lock_args_version, lock_lv_name);
+		rv = snprintf(vg_args, MAX_ARGS, "%s:%s", lock_args_version, lock_lv_name);
+		if (rv >= MAX_ARGS)
+			log_debug("init_vg_san vg_args may be too long %d %s", rv, vg_args);
 		return 0;
 	}
 
@@ -635,7 +639,9 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	if (!strcmp(gl_name, R_NAME_GL))
 		strncpy(gl_lsname_sanlock, ls_name, MAX_NAME);
  
-	snprintf(vg_args, MAX_ARGS, "%s:%s", lock_args_version, lock_lv_name);
+	rv = snprintf(vg_args, MAX_ARGS, "%s:%s", lock_args_version, lock_lv_name);
+	if (rv >= MAX_ARGS)
+		log_debug("init_vg_san vg_args may be too long %d %s", rv, vg_args);
 
 	log_debug("S %s init_vg_san done vg_args %s", ls_name, vg_args);
 
@@ -692,7 +698,7 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 {
 	struct sanlk_resourced rd;
 	char lock_lv_name[MAX_ARGS+1];
-	char lock_args_version[MAX_ARGS+1];
+	char lock_args_version[MAX_VERSION+1];
 	uint64_t offset;
 	int rv;
 
@@ -707,7 +713,7 @@ int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
 		return rv;
 	}
 
-	snprintf(lock_args_version, MAX_ARGS, "%u.%u.%u",
+	snprintf(lock_args_version, MAX_VERSION, "%u.%u.%u",
 		 LV_LOCK_ARGS_MAJOR, LV_LOCK_ARGS_MINOR, LV_LOCK_ARGS_PATCH);
 
 	if (daemon_test) {


