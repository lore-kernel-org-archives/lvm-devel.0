From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Mar 2019 13:46:18 -0400
Subject: master - lvextend: refresh shared LV remotely using dlm/corosync
Message-ID: <201903211746.x2LHkIV3030631@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85e68a8333722b7694d607652dd1f834fadfd8c4
Commit:        85e68a8333722b7694d607652dd1f834fadfd8c4
Parent:        d369de8399e14e82fb1ea45e7977d917411fbc21
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 20 13:20:26 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 21 12:38:20 2019 -0500

lvextend: refresh shared LV remotely using dlm/corosync

When lvextend extends an LV that is active with a shared
lock, use this as a signal that other hosts may also have
the LV active, with gfs2 mounted, and should have the LV
refreshed to reflect the new size.  Use the libdlmcontrol
run api, which uses dlm_controld/corosync to run an
lvchange --refresh command on other cluster nodes.
---
 configure.ac                         |   20 ++++
 daemons/lvmlockd/Makefile.in         |    1 +
 daemons/lvmlockd/lvmlockd-core.c     |   39 ++++++++
 daemons/lvmlockd/lvmlockd-dlm.c      |   73 +++++++++++++++
 daemons/lvmlockd/lvmlockd-internal.h |   14 +++
 lib/commands/toolcontext.h           |    1 +
 lib/locking/lvmlockd.c               |  165 +++++++++++++++++++++++++++++++---
 lib/locking/lvmlockd.h               |   17 ++++-
 lib/metadata/lv_manip.c              |    2 +-
 lib/metadata/metadata-exported.h     |    4 +
 tools/lvresize.c                     |    4 +
 11 files changed, 324 insertions(+), 16 deletions(-)

diff --git a/configure.ac b/configure.ac
index 2ece3f9..98a39f6 100644
--- a/configure.ac
+++ b/configure.ac
@@ -42,6 +42,7 @@ case "$host_os" in
 		BUILD_LVMPOLLD=no
 		LOCKDSANLOCK=no
 		LOCKDDLM=no
+		LOCKDDLM_CONTROL=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -917,6 +918,24 @@ if test "$BUILD_LOCKDDLM" = yes; then
 fi
 
 ################################################################################
+dnl -- Build lvmlockddlmcontrol
+AC_MSG_CHECKING(whether to build lvmlockddlmcontrol)
+AC_ARG_ENABLE(lvmlockd-dlmcontrol,
+	      AC_HELP_STRING([--enable-lvmlockd-dlmcontrol],
+			     [enable lvmlockd remote refresh using libdlmcontrol]),
+	      LOCKDDLM_CONTROL=$enableval)
+AC_MSG_RESULT($LOCKDDLM_CONTROL)
+
+BUILD_LOCKDDLM_CONTROL=$LOCKDDLM_CONTROL
+
+dnl -- Look for libdlmcontrol libraries
+if test "$BUILD_LOCKDDLM_CONTROL" = yes; then
+	PKG_CHECK_MODULES(LOCKD_DLM_CONTROL, libdlmcontrol >= 3.2, [HAVE_LOCKD_DLM_CONTROL=yes], $bailout)
+	AC_DEFINE([LOCKDDLM_CONTROL_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm control option.])
+	BUILD_LVMLOCKD=yes
+fi
+
+################################################################################
 dnl -- Build lvmlockd
 AC_MSG_CHECKING(whether to build lvmlockd)
 AC_MSG_RESULT($BUILD_LVMLOCKD)
@@ -1642,6 +1661,7 @@ AC_SUBST(BUILD_LVMPOLLD)
 AC_SUBST(BUILD_LVMLOCKD)
 AC_SUBST(BUILD_LOCKDSANLOCK)
 AC_SUBST(BUILD_LOCKDDLM)
+AC_SUBST(BUILD_LOCKDDLM_CONTROL)
 AC_SUBST(BUILD_DMFILEMAPD)
 AC_SUBST(CACHE)
 AC_SUBST(CFLAGS)
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 3ca4167..dca05b8 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -27,6 +27,7 @@ endif
 ifeq ("@BUILD_LOCKDDLM@", "yes")
   SOURCES += lvmlockd-dlm.c
   LOCK_LIBS += -ldlm_lt
+  LOCK_LIBS += -ldlmcontrol
 endif
 
 SOURCES2 = lvmlockctl.c
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index da3de54..ab413fb 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -502,6 +502,10 @@ static struct lock *alloc_lock(void)
 
 static void free_action(struct action *act)
 {
+	if (act->path) {
+		free(act->path);
+		act->path = NULL;
+	}
 	pthread_mutex_lock(&unused_struct_mutex);
 	if (unused_action_count >= MAX_UNUSED_ACTION) {
 		free(act);
@@ -739,6 +743,8 @@ static const char *op_str(int x)
 		return "dump_info";
 	case LD_OP_BUSY:
 		return "busy";
+	case LD_OP_REFRESH_LV:
+		return "refresh_lv";
 	default:
 		return "op_unknown";
 	};
@@ -3421,6 +3427,15 @@ static void *worker_thread_main(void *arg_in)
 			else
 				list_add(&act->list, &delayed_list);
 
+		} else if (act->op == LD_OP_REFRESH_LV) {
+			log_debug("work refresh_lv %s %s", act->lv_uuid, act->path);
+			rv = lm_refresh_lv_start_dlm(act);
+			if (rv < 0) {
+				act->result = rv;
+				add_client_result(act);
+			} else
+				list_add(&act->list, &delayed_list);
+
 		} else {
 			log_error("work unknown op %d", act->op);
 			act->result = -EINVAL;
@@ -3456,6 +3471,19 @@ static void *worker_thread_main(void *arg_in)
 					act->result = 0;
 					add_client_result(act);
 				}
+
+			} else if (act->op == LD_OP_REFRESH_LV) {
+				log_debug("work delayed refresh_lv");
+				rv = lm_refresh_lv_check_dlm(act);
+				if (!rv) {
+					list_del(&act->list);
+					act->result = 0;
+					add_client_result(act);
+				} else if ((rv < 0) && (rv != -EAGAIN)) {
+					list_del(&act->list);
+					act->result = rv;
+					add_client_result(act);
+				}
 			}
 		}
 
@@ -4061,6 +4089,11 @@ static int str_to_op_rt(const char *req_name, int *op, int *rt)
 		*rt = LD_RT_VG;
 		return 0;
 	}
+	if (!strcmp(req_name, "refresh_lv")) {
+		*op = LD_OP_REFRESH_LV;
+		*rt = 0;
+		return 0;
+	}
 out:
 	return -1;
 }
@@ -4422,6 +4455,7 @@ static void client_recv_action(struct client *cl)
 	const char *vg_name;
 	const char *vg_uuid;
 	const char *vg_sysid;
+	const char *path;
 	const char *str;
 	int64_t val;
 	uint32_t opts = 0;
@@ -4508,6 +4542,7 @@ static void client_recv_action(struct client *cl)
 	opts = str_to_opts(str);
 	str = daemon_request_str(req, "vg_lock_type", NULL);
 	lm = str_to_lm(str);
+	path = daemon_request_str(req, "path", NULL);
 
 	if (cl_pid && cl_pid != cl->pid)
 		log_error("client recv bad message pid %d client %d", cl_pid, cl->pid);
@@ -4540,6 +4575,9 @@ static void client_recv_action(struct client *cl)
 	act->flags = opts;
 	act->lm_type = lm;
 
+	if (path)
+		act->path = strdup(path);
+
 	if (vg_name && strcmp(vg_name, "none"))
 		strncpy(act->vg_name, vg_name, MAX_NAME);
 
@@ -4616,6 +4654,7 @@ static void client_recv_action(struct client *cl)
 	case LD_OP_STOP_ALL:
 	case LD_OP_RENAME_FINAL:
 	case LD_OP_RUNNING_LM:
+	case LD_OP_REFRESH_LV:
 		add_work_action(act);
 		rv = 0;
 		break;
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index e73be51..385d533 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -24,6 +24,7 @@
  * link with non-threaded version of library, libdlm_lt.
  */
 #include "libdlm.h"
+#include "libdlmcontrol.h"
 
 #include <stddef.h>
 #include <poll.h>
@@ -776,3 +777,75 @@ int lm_is_running_dlm(void)
 	return 1;
 }
 
+#ifdef LOCKDDLM_CONTROL_SUPPORT
+
+int lm_refresh_lv_start_dlm(struct action *act)
+{
+	char command[DLMC_RUN_COMMAND_LEN];
+	char run_uuid[DLMC_RUN_UUID_LEN];
+	int rv;
+
+	memset(command, 0, sizeof(command));
+	memset(run_uuid, 0, sizeof(run_uuid));
+
+	snprintf(command, DLMC_RUN_COMMAND_LEN,
+		 "lvm lvchange --refresh --nolocking %s", act->path);
+
+	rv = dlmc_run_start(command, strlen(command), 0,
+			    DLMC_FLAG_RUN_START_NODE_NONE,
+			    run_uuid);
+	if (rv < 0) {
+		log_debug("refresh_lv run_start error %d", rv);
+		return rv;
+	}
+
+	log_debug("refresh_lv run_start %s", run_uuid);
+
+	/* Bit of a hack here, we don't need path once started,
+	   but we do need to save the run_uuid somewhere, so just
+	   replace the path with the uuid. */
+
+	free(act->path);
+	act->path = strdup(run_uuid);
+	return 0;
+}
+
+int lm_refresh_lv_check_dlm(struct action *act)
+{
+	uint32_t check_status = 0;
+	int rv;
+
+	/* NB act->path was replaced with run_uuid */
+
+	rv = dlmc_run_check(act->path, strlen(act->path), 0,
+			    DLMC_FLAG_RUN_CHECK_CLEAR,
+			    &check_status);
+	if (rv < 0) {
+		log_debug("refresh_lv check error %d", rv);
+		return rv;
+	}
+
+	log_debug("refresh_lv check %s status %x", act->path, check_status);
+
+	if (!(check_status & DLMC_RUN_STATUS_DONE))
+		return -EAGAIN;
+
+	if (check_status & DLMC_RUN_STATUS_FAILED)
+		return -1;
+
+	return 0;
+}
+
+#else /* LOCKDDLM_CONTROL_SUPPORT */
+
+int lm_refresh_lv_start_dlm(struct action *act)
+{
+	return 0;
+}
+
+int lm_refresh_lv_check_dlm(struct action *act)
+{
+	return 0;
+}
+
+#endif /* LOCKDDLM_CONTROL_SUPPORT */
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 50015f1..85e8caf 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -54,6 +54,7 @@ enum {
 	LD_OP_DROP_VG,
 	LD_OP_BUSY,
 	LD_OP_QUERY_LOCK,
+	LD_OP_REFRESH_LV,
 };
 
 /* resource types */
@@ -129,6 +130,7 @@ struct action {
 	int max_retries;
 	int result;
 	int lm_rv;			/* return value from lm_ function */
+	char *path;
 	char vg_uuid[64];
 	char vg_name[MAX_NAME+1];
 	char lv_name[MAX_NAME+1];
@@ -391,6 +393,8 @@ int lm_get_lockspaces_dlm(struct list_head *ls_rejoin);
 int lm_data_size_dlm(void);
 int lm_is_running_dlm(void);
 int lm_hosts_dlm(struct lockspace *ls, int notify);
+int lm_refresh_lv_start_dlm(struct action *act);
+int lm_refresh_lv_check_dlm(struct action *act);
 
 static inline int lm_support_dlm(void)
 {
@@ -467,6 +471,16 @@ static inline int lm_hosts_dlm(struct lockspace *ls, int notify)
 	return 0;
 }
 
+static inline int lm_refresh_lv_start_dlm(struct action *act)
+{
+	return 0;
+}
+
+static inline int lm_refresh_lv_check_dlm(struct action *act)
+{
+	return 0;
+}
+
 #endif /* dlm support */
 
 #ifdef LOCKDSANLOCK_SUPPORT
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 959c153..2ce243e 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -160,6 +160,7 @@ struct cmd_context {
 	unsigned lockd_vg_default_sh:1;
 	unsigned lockd_vg_enforce_sh:1;
 	unsigned lockd_lv_sh:1;
+	unsigned lockd_lv_sh_for_ex:1;
 	unsigned vg_notify:1;
 	unsigned lv_notify:1;
 	unsigned pv_notify:1;
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index bc6e66f..60e0617 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -17,6 +17,8 @@
 #include "lib/cache/lvmcache.h"
 #include "daemons/lvmlockd/lvmlockd-client.h"
 
+#include <mntent.h>
+
 static daemon_handle _lvmlockd;
 static const char *_lvmlockd_socket = NULL;
 static int _use_lvmlockd = 0;         /* is 1 if command is configured to use lvmlockd */
@@ -2120,22 +2122,17 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		 * and using --lockopt skiplv to skip the incompat ex
 		 * lock, then check if an existing sh lock exists.
 		 */
-
-		if (!strcmp(cmd->name, "lvextend") ||
-		    !strcmp(cmd->name, "lvresize") ||
-		    !strcmp(cmd->name, "lvchange") ||
-		    !strcmp(cmd->name, "lvconvert")) {
+		if (!strcmp(cmd->name, "lvextend") || !strcmp(cmd->name, "lvresize") ||
+		    !strcmp(cmd->name, "lvchange") || !strcmp(cmd->name, "lvconvert")) {
 			int ex = 0, sh = 0;
 
 			if (!_query_lock_lv(cmd, vg, lv_name, lv_uuid, lock_args, &ex, &sh))
 				return 1;
-
 			if (sh) {
 				log_warn("WARNING: shared LV may require refresh on other hosts where it is active.");
 				return 1;
 			}
 		}
-
 		return 1;
 	}
 
@@ -2209,15 +2206,10 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		 * sh LV lock.
 		 */
 
-		/*
-		 * Special case to allow lvextend under gfs2.
-		 *
-		 * FIXME: verify the LV actually holds gfs2/ocfs2 which we know
-		 * allow this (other users of the LV may not.)
-		 */
 		if (lockd_flags & LD_RF_SH_EXISTS) {
-			if (flags & LDLV_EXTEND) {
+			if (flags & LDLV_SH_EXISTS_OK) {
 				log_warn("WARNING: extending LV with a shared lock, other hosts may require LV refresh.");
+				cmd->lockd_lv_sh_for_ex = 1;
 				return 1;
 			}
 		}
@@ -2399,6 +2391,110 @@ int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 			     lv->lock_args, def_mode, flags);
 }
 
+/*
+ * Check if the LV being resized is used by gfs2/ocfs2 which we
+ * know allow resizing under a shared lock.
+ */
+static int _shared_fs_can_resize(struct logical_volume *lv)
+{
+	FILE *f = NULL;
+	struct mntent *m;
+	int ret = 0;
+
+	if (!(f = setmntent("/etc/mtab", "r")))
+		return 0;
+
+	while ((m = getmntent(f))) {
+		if (!strcmp(m->mnt_type, "gfs2") || !strcmp(m->mnt_type, "ocfs2")) {
+			/* FIXME: check if this mntent is for lv */
+			ret = 1;
+			break;
+		}
+	}
+	endmntent(f);
+	return ret;
+}
+
+/*
+ * A special lockd_lv function is used for lvresize so that details can
+ * be saved for doing cluster "refresh" at the end of the command.
+ */
+
+int lockd_lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
+	     const char *def_mode, uint32_t flags,
+	     struct lvresize_params *lp)
+{
+	char lv_uuid[64] __attribute__((aligned(8)));
+	char path[PATH_MAX];
+	int shupdate = (lp->lockopt && strstr(lp->lockopt, "shupdate"));
+	int norefresh = (lp->lockopt && strstr(lp->lockopt, "norefresh"));
+	int rv;
+
+	if (!vg_is_shared(lv->vg))
+		return 1;
+
+	if (!_use_lvmlockd) {
+		log_error("LV in VG %s with lock_type %s requires lvmlockd.",
+			  lv->vg->name, lv->vg->lock_type);
+		return 0;
+	}
+
+	if (!_lvmlockd_connected)
+		return 0;
+
+	/*
+	 * A special case for gfs2 where we want to allow lvextend
+	 * of an LV that has an existing shared lock, which is normally
+	 * incompatible with the ex lock required by lvextend.
+	 *
+	 * Check if gfs2 or ocfs2 is mounted on the LV, and enable this
+	 * SH_EXISTS_OK flag if so.  Other users of the LV may not want
+	 * to allow this.  --lockopt shupdate allows the shared lock in
+	 * place of ex even we don't detect gfs2/ocfs2.
+	 */
+	if (lp->resize == LV_EXTEND) {
+		if (shupdate || _shared_fs_can_resize(lv))
+			flags |= LDLV_SH_EXISTS_OK;
+	}
+
+	rv = lockd_lv(cmd, lv, def_mode, flags);
+
+	if (norefresh)
+		return rv;
+
+	/*
+	 * If lockd_lv found an existing sh lock in lvmlockd and
+	 * used that in place of the usual ex lock (we allowed this
+	 * with SH_EXISTS_OK), then it sets this flag.
+	 *
+	 * We use this as a signal that we should try to refresh
+	 * the LV on remote nodes through dlm/corosync at the end
+	 * of the command.
+	 *
+	 * If lockd_lv sucessfully acquired the LV lock ex (did not
+	 * need to make use of SH_EXISTS_OK), then we know the LV
+	 * is active here only (or not active anywhere) and we
+	 * don't need to do any remote refresh.
+	 *
+	 * lvresize --lockopt norefresh disables the remote refresh.
+	 */
+	if (cmd->lockd_lv_sh_for_ex) {
+		if (!id_write_format(&lv->lvid.id[1], lv_uuid, sizeof(lv_uuid)))
+			return 0;
+		if (dm_snprintf(path, sizeof(path), "%s/%s/%s",
+				cmd->dev_dir, lv->vg->name, lv->name) < 0) {
+			log_error("LV path too long for lvmlockd refresh.");
+			return 0;
+		}
+
+		/* These will be used@the end of lvresize to do lockd_lv_refresh */
+		lp->lockd_lv_refresh_path = dm_pool_strdup(cmd->mem, path);
+		lp->lockd_lv_refresh_uuid = dm_pool_strdup(cmd->mem, lv_uuid);
+	}
+
+	return rv;
+}
+
 static int _init_lv_sanlock(struct cmd_context *cmd, struct volume_group *vg,
 			    const char *lv_name, struct id *lv_id,
 			    const char **lock_args_ret)
@@ -2915,3 +3011,44 @@ int lockd_lv_uses_lock(struct logical_volume *lv)
 
 	return 1;
 }
+
+/*
+ * send lvmlockd a request to use libdlmcontrol dlmc_run_start/dlmc_run_check
+ * to run a command on all nodes running dlm_controld:
+ * lvm lvchange --refresh --nolocking <path>
+ */
+
+int lockd_lv_refresh(struct cmd_context *cmd, struct lvresize_params *lp)
+{
+	daemon_reply reply;
+	char *lv_uuid = lp->lockd_lv_refresh_uuid;
+	char *path = lp->lockd_lv_refresh_path;
+	int result;
+
+	if (!lv_uuid || !path)
+		return 1;
+
+	log_warn("Refreshing LV %s on other hosts...", path);
+
+	reply = _lockd_send("refresh_lv",
+				"pid = " FMTd64, (int64_t) getpid(),
+				"opts = %s", "none",
+				"lv_uuid = %s", lv_uuid,
+				"path = %s", path,
+				NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		/* No result from lvmlockd, it is probably not running. */
+		log_error("LV refresh failed for LV %s", path);
+		return 0;
+	}
+	daemon_reply_destroy(reply);
+
+	if (result < 0) {
+		log_error("Failed to refresh LV on all hosts.");
+		log_error("Manual lvchange --refresh required on all hosts for %s.", path);
+		return 0;
+	}
+	return 1;
+}
+
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 53d077e..ecd39bb 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -22,7 +22,7 @@
 /* lockd_lv flags */
 #define LDLV_MODE_NO_SH           0x00000001
 #define LDLV_PERSISTENT           0x00000002
-#define LDLV_EXTEND               0x00000004
+#define LDLV_SH_EXISTS_OK         0x00000004
 
 /* lvmlockd result flags */
 #define LD_RF_NO_LOCKSPACES     0x00000001
@@ -82,6 +82,8 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		  const char *lock_args, const char *def_mode, uint32_t flags);
 int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	     const char *def_mode, uint32_t flags);
+int lockd_lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
+	     const char *def_mode, uint32_t flags, struct lvresize_params *lp);
 
 /* lvcreate/lvremove use init/free */
 
@@ -98,6 +100,8 @@ int handle_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg);
 
 int lockd_lv_uses_lock(struct logical_volume *lv);
 
+int lockd_lv_refresh(struct cmd_context *cmd, struct lvresize_params *lp);
+
 #else /* LVMLOCKD_SUPPORT */
 
 static inline void lvmlockd_set_socket(const char *sock)
@@ -208,6 +212,12 @@ static inline int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	return 1;
 }
 
+static inline int lockd_lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
+	     const char *def_mode, uint32_t flags, struct lvresize_params *lp)
+{
+	return 0;
+}
+
 static inline int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg,
 		  	struct logical_volume *lv, struct lvcreate_params *lp)
 {
@@ -242,6 +252,11 @@ static inline int lockd_lv_uses_lock(struct logical_volume *lv)
 	return 0;
 }
 
+static inline int lockd_lv_refresh(struct cmd_context *cmd, struct lvresize_params *lp)
+{
+	return 0;
+}
+
 #endif	/* LVMLOCKD_SUPPORT */
 
 #endif	/* _LVMLOCKD_H */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c21a0f9..cc391b6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5762,7 +5762,7 @@ int lv_resize(struct logical_volume *lv,
 	 * If the LV is locked from activation, this lock call is a no-op.
 	 * Otherwise, this acquires a transient lock on the lv (not PERSISTENT).
 	 */
-	if (!lockd_lv(cmd, lock_lv, "ex", (lp->resize == LV_EXTEND) ? LDLV_EXTEND : 0))
+	if (!lockd_lv_resize(cmd, lock_lv, "ex", 0, lp))
 		return_0;
 
 	if (!archive(vg))
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index df217db..0683d5f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -667,6 +667,10 @@ struct lvresize_params {
 	int approx_alloc;
 	int extents_are_pes;	/* Is 'extents' counting PEs or LEs? */
 	int size_changed;	/* Was there actually a size change */
+
+	const char *lockopt;
+	char *lockd_lv_refresh_path; /* set during resize to use for refresh at the end */
+	char *lockd_lv_refresh_uuid; /* set during resize to use for refresh at the end */
 };
 
 void pvcreate_params_set_defaults(struct pvcreate_params *pp);
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 9b061ac..0c72a81 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -152,6 +152,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->nofsck = arg_is_set(cmd, nofsck_ARG);
 	lp->nosync = arg_is_set(cmd, nosync_ARG);
 	lp->resizefs = arg_is_set(cmd, resizefs_ARG);
+	lp->lockopt = arg_str_value(cmd, lockopt_ARG, NULL);
 
 	return 1;
 }
@@ -205,5 +206,8 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 
 	destroy_processing_handle(cmd, handle);
 
+	if (lp.lockd_lv_refresh_path && !lockd_lv_refresh(cmd, &lp))
+		ret = ECMD_FAILED;
+
 	return ret;
 }


