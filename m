From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  5 Aug 2015 15:22:43 +0000 (UTC)
Subject: master - lvmlockd: handle loss of sanlock lease storage
Message-ID: <20150805152243.37286609D2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd1782b5fc41f3b9aceba6c27ba23098b0b4b6e2
Commit:        fd1782b5fc41f3b9aceba6c27ba23098b0b4b6e2
Parent:        559ca8bc6593a9ef0b0b012ff0933b80f5d3e367
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 31 13:38:38 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 5 10:21:45 2015 -0500

lvmlockd: handle loss of sanlock lease storage

This adds the infrastructure, code paths, error reporting,
etc. to handle storage errors, or storage loss, under the
sanlock leases in a VG that is being used.  The loss of
storage means sanlock cannot renew its leases, which means
that the host needs to stop using the shared VG before its
leases expire.

This still requires manually shutting down a VG that has
lost lease storage, e.g. unmounting file systems,
deactivating LVs in the VG.  The next step is to
automatically use a command like blkdeactivate to do that.
---
 daemons/lvmlockd/lvmlockctl.c        |  128 +++++++++++++++++++++--
 daemons/lvmlockd/lvmlockd-client.h   |    2 +
 daemons/lvmlockd/lvmlockd-core.c     |   99 ++++++++++++++++--
 daemons/lvmlockd/lvmlockd-internal.h |    4 +
 daemons/lvmlockd/lvmlockd-sanlock.c  |  189 ++++++++++++++++++++++++----------
 lib/locking/lvmlockd.c               |   75 +++++++++++---
 lib/locking/lvmlockd.h               |    3 +-
 7 files changed, 415 insertions(+), 85 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index cb67296..148077e 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -17,6 +17,7 @@
 #include <signal.h>
 #include <errno.h>
 #include <fcntl.h>
+#include <syslog.h>
 #include <sys/wait.h>
 #include <sys/socket.h>
 #include <sys/un.h>
@@ -26,14 +27,16 @@ static int info = 0;
 static int dump = 0;
 static int wait_opt = 0;
 static int force_opt = 0;
+static int kill_vg = 0;
+static int drop_vg = 0;
 static int gl_enable = 0;
 static int gl_disable = 0;
 static int stop_lockspaces = 0;
-static char *able_vg_name = NULL;
+static char *arg_vg_name = NULL;
 
 #define DUMP_SOCKET_NAME "lvmlockd-dump.sock"
 #define DUMP_BUF_SIZE (1024 * 1024)
-static char dump_buf[DUMP_BUF_SIZE];
+static char dump_buf[DUMP_BUF_SIZE+1];
 static int dump_len;
 static struct sockaddr_un dump_addr;
 static socklen_t dump_addrlen;
@@ -446,9 +449,9 @@ static int do_able(const char *req_name)
 	int rv;
 
 	reply = _lvmlockd_send(req_name,
-				"cmd = %s", "lvmlock",
+				"cmd = %s", "lvmlockctl",
 				"pid = %d", getpid(),
-				"vg_name = %s", able_vg_name,
+				"vg_name = %s", arg_vg_name,
 				NULL);
 
 	if (!_lvmlockd_result(reply, &result)) {
@@ -477,7 +480,7 @@ static int do_stop_lockspaces(void)
 		strcat(opts, "force ");
 
 	reply = _lvmlockd_send("stop_all",
-				"cmd = %s", "lvmlock",
+				"cmd = %s", "lvmlockctl",
 				"pid = %d", getpid(),
 				"opts = %s", opts[0] ? opts : "none",
 				NULL);
@@ -493,6 +496,87 @@ static int do_stop_lockspaces(void)
 	return rv;
 }
 
+static int do_kill(void)
+{
+	daemon_reply reply;
+	int result;
+	int rv;
+
+	syslog(LOG_EMERG, "Lost access to sanlock lease storage in VG %s.", arg_vg_name);
+	/* These two lines explain the manual alternative to the FIXME below. */
+	syslog(LOG_EMERG, "Immediately deactivate LVs in VG %s.", arg_vg_name);
+	syslog(LOG_EMERG, "Once VG is unused, run lvmlockctl --drop %s.", arg_vg_name);
+
+	/*
+	 * It may not be strictly necessary to notify lvmlockd of the kill, but
+	 * lvmlockd can use this information to avoid attempting any new lock
+	 * requests in the VG (which would fail anyway), and can return an
+	 * error indicating that the VG has been killed.
+	 */
+
+	reply = _lvmlockd_send("kill_vg",
+				"cmd = %s", "lvmlockctl",
+				"pid = %d", getpid(),
+				"vg_name = %s", arg_vg_name,
+				NULL);
+
+	if (!_lvmlockd_result(reply, &result)) {
+		log_error("lvmlockd result %d", result);
+		rv = result;
+	} else {
+		rv = 0;
+	}
+
+	daemon_reply_destroy(reply);
+
+	/*
+	 * FIXME: here is where we should implement a strong form of
+	 * blkdeactivate, and if it completes successfully, automatically call
+	 * do_drop() afterward.  (The drop step may not always be necessary
+	 * if the lvm commands run while shutting things down release all the
+	 * leases.)
+	 *
+	 * run_strong_blkdeactivate();
+	 * do_drop();
+	 */
+
+	return rv;
+}
+
+static int do_drop(void)
+{
+	daemon_reply reply;
+	int result;
+	int rv;
+
+	syslog(LOG_WARNING, "Dropping locks for VG %s.", arg_vg_name);
+
+	/*
+	 * Check for misuse by looking for any active LVs in the VG
+	 * and refusing this operation if found?  One possible way
+	 * to kill LVs (e.g. if fs cannot be unmounted) is to suspend
+	 * them, or replace them with the error target.  In that
+	 * case the LV will still appear to be active, but it is
+	 * safe to release the lock.
+	 */
+
+	reply = _lvmlockd_send("drop_vg",
+				"cmd = %s", "lvmlockctl",
+				"pid = %d", getpid(),
+				"vg_name = %s", arg_vg_name,
+				NULL);
+
+	if (!_lvmlockd_result(reply, &result)) {
+		log_error("lvmlockd result %d", result);
+		rv = result;
+	} else {
+		rv = 0;
+	}
+
+	daemon_reply_destroy(reply);
+	return rv;
+}
+
 static void print_usage(void)
 {
 	printf("lvmlockctl options\n");
@@ -509,12 +593,16 @@ static void print_usage(void)
 	printf("      Wait option for other commands.\n");
 	printf("--force | -f 0|1>\n");
 	printf("      Force option for other commands.\n");
-	printf("--stop-lockspaces | -S\n");
-	printf("      Stop all lockspaces.\n");
+	printf("--kill | -k <vg_name>\n");
+	printf("      Kill access to the vg when sanlock cannot renew lease.\n");
+	printf("--drop | -r <vg_name>\n");
+	printf("      Clear locks for the vg after it has been killed and is no longer used.\n");
 	printf("--gl-enable <vg_name>\n");
 	printf("      Tell lvmlockd to enable the global lock in a sanlock vg.\n");
 	printf("--gl-disable <vg_name>\n");
 	printf("      Tell lvmlockd to disable the global lock in a sanlock vg.\n");
+	printf("--stop-lockspaces | -S\n");
+	printf("      Stop all lockspaces.\n");
 }
 
 static int read_options(int argc, char *argv[])
@@ -529,6 +617,8 @@ static int read_options(int argc, char *argv[])
 		{"dump",            no_argument,       0,  'd' },
 		{"wait",            required_argument, 0,  'w' },
 		{"force",           required_argument, 0,  'f' },
+		{"kill",            required_argument, 0,  'k' },
+		{"drop",            required_argument, 0,  'r' },
 		{"gl-enable",       required_argument, 0,  'E' },
 		{"gl-disable",      required_argument, 0,  'D' },
 		{"stop-lockspaces", no_argument,       0,  'S' },
@@ -541,7 +631,7 @@ static int read_options(int argc, char *argv[])
 	}
 
 	while (1) {
-		c = getopt_long(argc, argv, "hqidE:D:w:S", long_options, &option_index);
+		c = getopt_long(argc, argv, "hqidE:D:w:k:r:S", long_options, &option_index);
 		if (c == -1)
 			break;
 
@@ -565,13 +655,21 @@ static int read_options(int argc, char *argv[])
 		case 'w':
 			wait_opt = atoi(optarg);
 			break;
+		case 'k':
+			kill_vg = 1;
+			arg_vg_name = strdup(optarg);
+			break;
+		case 'r':
+			drop_vg = 1;
+			arg_vg_name = strdup(optarg);
+			break;
 		case 'E':
 			gl_enable = 1;
-			able_vg_name = strdup(optarg);
+			arg_vg_name = strdup(optarg);
 			break;
 		case 'D':
 			gl_disable = 1;
-			able_vg_name = strdup(optarg);
+			arg_vg_name = strdup(optarg);
 			break;
 		case 'S':
 			stop_lockspaces = 1;
@@ -616,6 +714,16 @@ int main(int argc, char **argv)
 		goto out;
 	}
 
+	if (kill_vg) {
+		rv = do_kill();
+		goto out;
+	}
+
+	if (drop_vg) {
+		rv = do_drop();
+		goto out;
+	}
+
 	if (gl_enable) {
 		rv = do_able("enable_gl");
 		goto out;
diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
index e1d69d2..0a1424f 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -45,5 +45,7 @@ static inline void lvmlockd_close(daemon_handle h)
 #define EMANAGER  214
 #define EPREPARE  215
 #define ELOCKD    216
+#define EVGKILLED 217 /* sanlock lost access to leases and VG is killed. */
+#define ELOCKIO   218 /* sanlock io errors during lock op, may be transient. */
 
 #endif	/* _LVM_LVMLOCKD_CLIENT_H */
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 266339d..7493d11 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -735,6 +735,10 @@ static const char *op_str(int x)
 		return "find_free_lock";
 	case LD_OP_FORGET_VG_NAME:
 		return "forget_vg_name";
+	case LD_OP_KILL_VG:
+		return "kill_vg";
+	case LD_OP_DROP_VG:
+		return "drop_vg";
 	default:
 		return "op_unknown";
 	};
@@ -786,6 +790,7 @@ int version_from_args(char *args, unsigned int *major, unsigned int *minor, unsi
 	char *major_str, *minor_str, *patch_str;
 	char *n, *d1, *d2;
 
+	memset(version, 0, sizeof(version));
 	strncpy(version, args, MAX_ARGS);
 	version[MAX_ARGS] = '\0';
 
@@ -1828,7 +1833,7 @@ static int for_each_lock(struct lockspace *ls, int locks_do)
 	return 0;
 }
 
-static int clear_locks(struct lockspace *ls, int free_vg)
+static int clear_locks(struct lockspace *ls, int free_vg, int drop_vg)
 {
 	struct resource *r, *r_safe;
 	struct lock *lk, *lk_safe;
@@ -1847,10 +1852,10 @@ static int clear_locks(struct lockspace *ls, int free_vg)
 			/*
 			 * Stopping a lockspace shouldn't happen with LV locks
 			 * still held, but it will be stopped with GL and VG
-			 * locks held.
+			 * locks held.  The drop_vg case may see LV locks.
 			 */
 
-			if (lk->flags & LD_LF_PERSISTENT)
+			if (lk->flags & LD_LF_PERSISTENT && !drop_vg)
 				log_error("S %s R %s clear lock persistent", ls->name, r->name);
 			else
 				log_debug("S %s R %s clear lock mode %s client %d", ls->name, r->name, mode_str(lk->mode), lk->client_id);
@@ -1884,8 +1889,8 @@ static int clear_locks(struct lockspace *ls, int free_vg)
 		rv = lm_unlock(ls, r, NULL, r_version, free_vg ? LMUF_FREE_VG : 0);
 		if (rv < 0) {
 			/* should never happen */
-			log_error("S %s R %s clear_locks free %d lm unlock error %d",
-				  ls->name, r->name, free_vg, rv);
+			log_error("S %s R %s clear_locks free %d drop %d lm unlock error %d",
+				  ls->name, r->name, free_vg, drop_vg, rv);
 		}
 
 		list_for_each_entry_safe(act, act_safe, &r->actions, list) {
@@ -1991,6 +1996,28 @@ static int other_sanlock_vgs_exist(struct lockspace *ls_rem)
 }
 
 /*
+ * LOCK is the main thing we're interested in; the others are unlikely.
+ */
+
+static int process_op_during_kill(struct action *act)
+{
+	if (act->op == LD_OP_LOCK && act->mode == LD_LK_UN)
+		return 1;
+
+	switch (act->op) {
+	case LD_OP_LOCK:
+	case LD_OP_ENABLE:
+	case LD_OP_DISABLE:
+	case LD_OP_UPDATE:
+	case LD_OP_RENAME_BEFORE:
+	case LD_OP_RENAME_FINAL:
+	case LD_OP_FIND_FREE_LOCK:
+		return 0;
+	};
+	return 1;
+}
+
+/*
  * Process actions queued for this lockspace by
  * client_recv_action / add_lock_action.
  *
@@ -2010,6 +2037,7 @@ static void *lockspace_thread_main(void *arg_in)
 	struct list_head tmp_act;
 	struct list_head act_close;
 	int free_vg = 0;
+	int drop_vg = 0;
 	int error = 0;
 	int adopt_flag = 0;
 	int wait_flag = 0;
@@ -2114,7 +2142,43 @@ static void *lockspace_thread_main(void *arg_in)
 
 			act = list_first_entry(&ls->actions, struct action, list);
 
+			if (act->op == LD_OP_KILL_VG && act->rt == LD_RT_VG) {
+				/* Continue processing until DROP_VG arrives. */
+				log_debug("S %s kill_vg", ls->name);
+				ls->kill_vg = 1;
+				list_del(&act->list);
+				act->result = 0;
+				add_client_result(act);
+				continue;
+			}
+
+			if (ls->kill_vg && !process_op_during_kill(act)) {
+				log_debug("S %s disallow op %s after kill_vg", ls->name, op_str(act->op));
+				list_del(&act->list);
+				act->result = -EVGKILLED;
+				add_client_result(act);
+				continue;
+			}
+
+			if (act->op == LD_OP_DROP_VG && act->rt == LD_RT_VG) {
+				/*
+				 * If leases are released after i/o errors begin
+				 * but before lvmlockctl --kill, then the VG is not
+				 * killed, but drop is still needed to clean up the
+				 * VG, so in that case there would be a drop op without
+				 * a preceding kill op.
+				 */
+				if (!ls->kill_vg)
+					log_debug("S %s received drop without kill", ls->name);
+				log_debug("S %s drop_vg", ls->name);
+				ls->thread_work = 0;
+				ls->thread_stop = 1;
+				drop_vg = 1;
+				break;
+			}
+
 			if (act->op == LD_OP_STOP) {
+				/* thread_stop is already set */
 				ls->thread_work = 0;
 				break;
 			}
@@ -2238,6 +2302,9 @@ out_rem:
 	 * allowed in emergency/force situations, otherwise it's
 	 * obviously dangerous, since the lock holders are still
 	 * operating under the assumption that they hold the lock.
+	 * drop_vg drops all existing locks, but should only
+	 * happen when the VG access has been forcibly and
+	 * succesfully terminated.
 	 *
 	 * For vgremove of a sanlock vg, the vg lock will be held,
 	 * and possibly the gl lock if this vg holds the gl.
@@ -2246,7 +2313,7 @@ out_rem:
 
 	log_debug("S %s clearing locks", ls->name);
 
-	rv = clear_locks(ls, free_vg);
+	rv = clear_locks(ls, free_vg, drop_vg);
 
 	/*
 	 * Tell any other hosts in the lockspace to leave it
@@ -2284,6 +2351,8 @@ out_act:
 			act->result = 0;
 		} else if (act->op == LD_OP_STOP)
 			act->result = 0;
+		else if (act->op == LD_OP_DROP_VG)
+			act->result = 0;
 		else if (act->op == LD_OP_RENAME_BEFORE)
 			act->result = 0;
 		else
@@ -2317,6 +2386,7 @@ out_act:
 	pthread_mutex_lock(&lockspaces_mutex);
 	ls->thread_done = 1;
 	ls->free_vg = free_vg;
+	ls->drop_vg = drop_vg;
 	pthread_mutex_unlock(&lockspaces_mutex);
 
 	/*
@@ -3539,7 +3609,6 @@ static int add_lock_action(struct action *act)
 			if (ls_create_fail)
 				act->flags |= LD_AF_ADD_LS_ERROR;
 			return -ENOLS;
-
 		} else {
 			log_debug("lockspace not found %s", ls_name);
 			return -ENOLS;
@@ -3714,6 +3783,16 @@ static int str_to_op_rt(const char *req_name, int *op, int *rt)
 		*rt = LD_RT_VG;
 		return 0;
 	}
+	if (!strcmp(req_name, "kill_vg")) {
+		*op = LD_OP_KILL_VG;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "drop_vg")) {
+		*op = LD_OP_DROP_VG;
+		*rt = LD_RT_VG;
+		return 0;
+	}
 out:
 	return -1;
 }
@@ -3864,6 +3943,8 @@ static int print_lockspace(struct lockspace *ls, const char *prefix, int pos, in
 			"thread_work=%d "
 			"thread_stop=%d "
 			"thread_done=%d "
+			"kill_vg=%d "
+			"drop_vg=%d "
 			"sanlock_gl_enabled=%d\n",
 			prefix,
 			ls->name,
@@ -3878,6 +3959,8 @@ static int print_lockspace(struct lockspace *ls, const char *prefix, int pos, in
 			ls->thread_work ? 1 : 0,
 			ls->thread_stop ? 1 : 0,
 			ls->thread_done ? 1 : 0,
+			ls->kill_vg,
+			ls->drop_vg,
 			ls->sanlock_gl_enabled ? 1 : 0);
 }
 
@@ -4273,6 +4356,8 @@ static void client_recv_action(struct client *cl)
 	case LD_OP_FREE:
 	case LD_OP_RENAME_BEFORE:
 	case LD_OP_FIND_FREE_LOCK:
+	case LD_OP_KILL_VG:
+	case LD_OP_DROP_VG:
 		rv = add_lock_action(act);
 		break;
 	case LD_OP_FORGET_VG_NAME:
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 78ae88d..a1f74a7 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -51,6 +51,8 @@ enum {
 	LD_OP_RUNNING_LM,
 	LD_OP_FIND_FREE_LOCK,
 	LD_OP_FORGET_VG_NAME,
+	LD_OP_KILL_VG,
+	LD_OP_DROP_VG,
 };
 
 /* resource types */
@@ -184,6 +186,8 @@ struct lockspace {
 	unsigned int sanlock_gl_enabled: 1;
 	unsigned int sanlock_gl_dup: 1;
 	unsigned int free_vg: 1;
+	unsigned int kill_vg: 1;
+	unsigned int drop_vg: 1;
 
 	struct list_head actions;	/* new client actions */
 	struct list_head resources;	/* resource/lock state for gl/vg/lv */
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 44926da..4317aad 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -33,52 +33,101 @@
 #include <sys/socket.h>
 
 /*
- * If access to the pv containing the vg's leases is lost, sanlock cannot renew
- * the leases we have acquired for locked LVs.  This means that we could soon
- * loose the lease to another host which could activate our LV exclusively.  We
- * do not want to get to the point of two hosts having the same LV active
- * exclusively (it obviously violates the purpose of LV locks.)
- *
- * The default method of preventing this problem is for lvmlockd to do nothing,
- * which produces a safe but potentially inconvenient result.  Doing nothing
- * leads to our LV leases not being released, which leads to sanlock using the
- * local watchdog to reset us before another host can acquire our lock.  It
- * would often be preferrable to avoid the abrupt hard reset from the watchdog.
- *
- * There are other options to avoid being reset by our watchdog.  If we can
- * quickly stop using the LVs in question and release the locks for them, then
- * we could avoid a reset (there's a certain grace period of about 40 seconds
- * in which we can attempt this.)  To do this, we can tell sanlock to run a
- * specific program when it has lost access to our leases.  We could use this
- * program to:
- *
- * 1. Deactivate all lvs in the effected vg.  If all the leases are
- * deactivated, then our LV locks would be released and sanlock would no longer
- * use the watchdog to reset us.  If file systems are mounted on the active
- * lvs, then deactivating them would fail, so this option would be of limited
- * usefulness.
- *
- * 2. Option 1 could be extended to kill pids using the fs on the lv, unmount
- * the fs, and deactivate the lv.  This is probably out of scope for lvm
- * directly, and would likely need the help of another system service.
- *
- * 3. Use dmsetup suspend to block access to lvs in the effected vg.  If this
- * was successful, the local host could no longer write to the lvs, we could
- * safely release the LV locks, and sanlock would no longer reset us.  At this
- * point, with suspended lvs, the host would be in a fairly hobbled state, and
- * would almost certainly need a manual, forcible reset.
- *
- * 4. Option 3 could be extended to monitor the lost storage, and if it is
- * reconnected, the leases could be reacquired, and the suspended lvs resumed
- * (reacquiring leases will fail if another host has acquired them since they
- * were released.)  This complexity of this option, combined with the fact that
- * the error conditions are often not as simple as storage being lost and then
- * later connecting, will result in this option being too unreliable.
- *
- * Add a config option that we could use to select a different behavior than
- * the default.  Then implement one of the simpler options as a proof of
- * concept, which could be extended if needed.
- */
+-------------------------------------------------------------------------------
+For each VG, lvmlockd creates a sanlock lockspace that holds the leases for
+that VG.  There's a lease for the VG lock, and there's a lease for each active
+LV.  sanlock maintains (reads/writes) these leases, which exist on storage.
+That storage is a hidden LV within the VG: /dev/vg/lvmlock.  lvmlockd gives the
+path of this internal LV to sanlock, which then reads/writes the leases on it.
+
+# lvs -a cc -o+uuid
+  LV        VG   Attr       LSize   LV UUID
+  lv1       cc   -wi-a-----   2.00g 7xoDtu-yvNM-iwQx-C94t-BbYs-UzBl-o8hAIa
+  lv2       cc   -wi-a----- 100.00g exxNPX-wZdO-uCNy-yiGa-aJGT-JKVl-arfcYT
+  [lvmlock] cc   -wi-ao---- 256.00m iLpDel-hR0T-hJ3u-rnVo-PcDh-mcjt-sF9egM
+
+# sanlock status
+s lvm_cc:1:/dev/mapper/cc-lvmlock:0
+r lvm_cc:exxNPX-wZdO-uCNy-yiGa-aJGT-JKVl-arfcYT:/dev/mapper/cc-lvmlock:71303168:13 p 26099
+r lvm_cc:7xoDtu-yvNM-iwQx-C94t-BbYs-UzBl-o8hAIa:/dev/mapper/cc-lvmlock:70254592:3 p 26099
+
+This shows that sanlock is maintaining leases on /dev/mapper/cc-lvmlock.
+
+sanlock acquires a lockspace lease when the lockspace is joined, i.e. when the
+VG is started by 'vgchange --lock-start cc'.  This lockspace lease exists at
+/dev/mapper/cc-lvmlock offset 0, and sanlock regularly writes to it to maintain
+ownership of it.  Joining the lockspace (by acquiring the lockspace lease in
+it) then allows standard resource leases to be acquired in the lockspace for
+whatever the application wants.  lvmlockd uses resource leases for the VG lock
+and LV locks.
+
+sanlock acquires a resource lease for each actual lock that lvm commands use.
+Above, there are two LV locks that are held because the two LVs are active.
+These are on /dev/mapper/cc-lvmlock at offsets 71303168 and 70254592.  sanlock
+does not write to these resource leases except when acquiring and releasing
+them (e.g. lvchange -ay/-an).  The renewal of the lockspace lease maintains
+ownership of all the resource leases in the lockspace.
+
+If the host loses access to the disk that the sanlock lv lives on, then sanlock
+can no longer renew its lockspace lease.  The lockspace lease will eventually
+expire, at which point the host will lose ownership of it, and of all resource
+leases it holds in the lockspace.  Eventually, other hosts will be able to
+acquire those leases.  sanlock ensures that another host will not be able to
+acquire one of the expired leases until the current host has quit using it.
+
+It is important that the host "quit using" the leases it is holding if the
+sanlock storage is lost and they begin expiring.  If the host cannot quit using
+the leases and release them within a limited time, then sanlock will use the
+local watchdog to forcibly reset the host before any other host can acquire
+them.  This is severe, but preferable to possibly corrupting the data protected
+by the lease.  It ensures that two nodes will not be using the same lease at
+once.  For LV leases, that means that another host will not be able to activate
+the LV while another host still has it active.
+
+sanlock notifies the application that it cannot renew the lockspace lease.  The
+application needs to quit using all leases in the lockspace and release them as
+quickly as possible.  In the initial version, lvmlockd ignored this
+notification, so sanlock would eventually reach the point where it would use
+the local watchdog to reset the host.  However, it's better to attempt a
+response.  If that response succeeds, the host can avoid being reset.  If the
+response fails, then sanlock will eventually reset the host as the last resort.
+sanlock gives the application about 40 seconds to complete its response and
+release its leases before resetting the host.
+
+An application can specify the path and args of a program that sanlock should
+run to notify it if the lockspace lease cannot be renewed.  This program should
+carry out the application's response to the expiring leases: attempt to quit
+using the leases and then release them.  lvmlockd gives this command to sanlock
+for each VG when that VG is started: 'lvmlockctl --kill vg_name'
+
+If sanlock loses access to lease storage in that VG, it runs lvmlockctl --kill,
+which:
+
+1. Uses syslog to explain what is happening.
+
+2. Notifies lvmlockd that the VG is being killed, so lvmlockd can
+   immediatley return an error for this condition if any new lock
+   requests are made.  (This step would not be strictly necessary.)
+
+3. Attempts to quit using the VG.  This is not yet implemented, but
+   will eventually use blkdeactivate on the VG (or a more forceful
+   equivalent.)
+
+4. If step 3 was successful at terminating all use of the VG, then
+   lvmlockd is told to release all the leases for the VG.  If this
+   is all done without about 40 seconds, the host can avoid being
+   reset.
+
+Until steps 3 and 4 are fully implemented, manual steps can be substituted.
+This is primarily for testing since the problem needs to be noticed and
+responded to in a very short time.  The manual alternative to step 3 is to kill
+any processes using file systems on LV's in the VG, unmount all file systems on
+the LVs, and deactivate all the LVs.  Once this is done, the manual alternative
+to step 4 is to run 'lvmlockctl --drop vg_name', which tells lvmlockd to
+release all the leases for the VG.
+-------------------------------------------------------------------------------
+*/
+
 
 /*
  * Each lockspace thread has its own sanlock daemon connection.
@@ -961,12 +1010,24 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 	char lock_lv_name[MAX_ARGS+1];
 	char lsname[SANLK_NAME_LEN + 1];
 	char disk_path[SANLK_PATH_LEN];
+	char killpath[SANLK_PATH_LEN];
+	char killargs[SANLK_PATH_LEN];
 	int gl_found;
 	int ret, rv;
 
 	memset(disk_path, 0, sizeof(disk_path));
 	memset(lock_lv_name, 0, sizeof(lock_lv_name));
 
+	/*
+	 * Construct the path to lvmlockctl by using the path to the lvm binary
+	 * and appending "lockctl" to get /path/to/lvmlockctl.
+	 */
+	memset(killpath, 0, sizeof(killpath));
+	snprintf(killpath, SANLK_PATH_LEN - 1, "%slockctl", LVM_PATH);
+
+	memset(killargs, 0, sizeof(killargs));
+	snprintf(killargs, SANLK_PATH_LEN - 1, "--kill %s", ls->vg_name);
+
 	rv = check_args_version(ls->vg_args, VG_LOCK_ARGS_MAJOR);
 	if (rv < 0) {
 		ret = -EARGS;
@@ -1051,6 +1112,15 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 		goto fail;
 	}
 
+	log_debug("set killpath to %s %s", killpath, killargs);
+
+	rv = sanlock_killpath(lms->sock, 0, killpath, killargs);
+	if (rv < 0) {
+		log_error("S %s killpath error %d", lsname, rv);
+		ret = -EMANAGER;
+		goto fail;
+	}
+
 	rv = sanlock_restrict(lms->sock, SANLK_RESTRICT_SIGKILL);
 	if (rv < 0) {
 		log_error("S %s restrict error %d", lsname, rv);
@@ -1397,11 +1467,6 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 		log_error("S %s R %s lock_san acquire error %d",
 			  ls->name, r->name, rv);
 
-		if (added) {
-			lm_rem_resource_sanlock(ls, r);
-			return rv;
-		}
-
 		/* if the gl has been disabled, remove and free the gl resource */
 		if ((rv == SANLK_LEADER_RESOURCE) && (r->type == LD_RT_GL)) {
 			if (!lm_gl_is_enabled(ls)) {
@@ -1413,6 +1478,22 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 			}
 		}
 
+		if (added)
+			lm_rem_resource_sanlock(ls, r);
+
+		/* sanlock gets i/o errors trying to read/write the leases. */
+		if (rv == -EIO)
+			rv = -ELOCKIO;
+
+		/*
+		 * The sanlock lockspace can disappear if the lease storage fails,
+		 * the delta lease renewals fail, the lockspace enters recovery,
+		 * lvmlockd holds no leases in the lockspace, so sanlock can
+		 * stop and free the lockspace.
+		 */
+		if (rv == -ENOSPC)
+			rv = -ELOCKIO;
+
 		return rv;
 	}
 
@@ -1594,9 +1675,11 @@ int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
 	}
 
 	rv = sanlock_release(lms->sock, -1, 0, 1, &rs);
-	if (rv < 0) {
+	if (rv < 0)
 		log_error("S %s R %s unlock_san release error %d", ls->name, r->name, rv);
-	}
+
+	if (rv == -EIO)
+		rv = -ELOCKIO;
 
 	return rv;
 }
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 4e85ec1..7f14a86 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1357,6 +1357,7 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 	const char *mode = NULL;
 	const char *opts = NULL;
 	uint32_t lockd_flags;
+	int force_cache_update = 0;
 	int retries = 0;
 	int result;
 
@@ -1401,8 +1402,8 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 		/* We can continue reading if a shared lock fails. */
 		if (!strcmp(mode, "sh")) {
 			log_warn("Reading without shared global lock.");
-			lvmetad_validate_global_cache(cmd, 1);
-			return 1;
+			force_cache_update = 1;
+			goto allow;
 		}
 
 		log_error("Global lock failed: check that lvmlockd is running.");
@@ -1425,9 +1426,19 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 	 *
 	 * ESTARTING: the lockspace with the gl is starting.
 	 * The VG with the global lock is starting and should finish shortly.
+	 *
+	 * ELOCKIO: sanlock gets i/o errors when trying to read/write leases
+	 * (This can progress to EVGKILLED.)
+	 *
+	 * EVGKILLED: the sanlock lockspace is being killed after losing
+	 * access to lease storage.
 	 */
 
-	if (result == -ENOLS || result == -ESTARTING) {
+	if (result == -ENOLS ||
+	    result == -ESTARTING ||
+	    result == -EVGKILLED ||
+	    result == -ELOCKIO) {
+
 		if (!strcmp(mode, "un"))
 			return 1;
 
@@ -1436,9 +1447,13 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 		 */
 		if (strcmp(mode, "sh")) {
 			if (result == -ESTARTING)
-				log_error("Global lock failed: lockspace is starting.");
+				log_error("Global lock failed: lockspace is starting");
 			else if (result == -ENOLS)
-				log_error("Global lock failed: check that global lockspace is started.");
+				log_error("Global lock failed: check that global lockspace is started");
+			else if (result == -ELOCKIO)
+				log_error("Global lock failed: storage errors for sanlock leases");
+			else if (result == -EVGKILLED)
+				log_error("Global lock failed: storage failed for sanlock leases");
 			else
 				log_error("Global lock failed: error %d", result);
 			return 0;
@@ -1452,14 +1467,21 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 
 		if (result == -ESTARTING) {
 			log_warn("Skipping global lock: lockspace is starting");
-			lvmetad_validate_global_cache(cmd, 1);
-			return 1;
+			force_cache_update = 1;
+			goto allow;
+		}
+
+		if (result == -ELOCKIO || result == -EVGKILLED) {
+			log_warn("Skipping global lock: storage %s for sanlock leases",
+				  result == -ELOCKIO ? "errors" : "failed");
+			force_cache_update = 1;
+			goto allow;
 		}
 
 		if ((lockd_flags & LD_RF_NO_GL_LS) || (lockd_flags & LD_RF_NO_LOCKSPACES)) {
 			log_warn("Skipping global lock: lockspace not found or started");
-			lvmetad_validate_global_cache(cmd, 1);
-			return 1;
+			force_cache_update = 1;
+			goto allow;
 		}
 
 		/*
@@ -1492,9 +1514,8 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 		}
 	}
 
-	if (!(flags & LDGL_SKIP_CACHE_VALIDATE))
-		lvmetad_validate_global_cache(cmd, 0);
-
+ allow:
+	lvmetad_validate_global_cache(cmd, force_cache_update);
 	return 1;
 }
 
@@ -1510,7 +1531,7 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
  *
  * The result of the VG lock operation needs to be saved in lockd_state
  * because the result needs to be passed into vg_read so it can be
- * assessed in combination with vg->lock_state.
+ * assessed in combination with vg->lock_type.
  *
  * The VG lock protects the VG metadata on disk from concurrent access
  * among hosts.  The VG lock also ensures that the local lvmetad cache
@@ -1687,6 +1708,28 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	}
 
 	/*
+	 * sanlock is getting i/o errors while reading/writing leases, or the
+	 * lockspace/VG is being killed after failing to renew its lease for
+	 * too long.
+	 */
+	if (result == -EVGKILLED || result == -ELOCKIO) {
+		const char *problem = (result == -ELOCKIO ? "errors" : "failed");
+
+		if (!strcmp(mode, "un")) {
+			ret = 1;
+			goto out;
+		} else if (!strcmp(mode, "sh")) {
+			log_warn("VG %s lock skipped: storage %s for sanlock leases", vg_name, problem);
+			ret = 1;
+			goto out;
+		} else {
+			log_error("VG %s lock failed: storage %s for sanlock leases", vg_name, problem);
+			ret = 0;
+			goto out;
+		}
+	}
+
+	/*
 	 * An unused/previous lockspace for the VG was found.
 	 * This means it must be a lockd VG, not local.  The
 	 * lockspace needs to be started to be used.
@@ -1903,6 +1946,12 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
+	if (result == -EVGKILLED || result == -ELOCKIO) {
+		const char *problem = (result == -ELOCKIO ? "errors" : "failed");
+		log_error("LV %s/%s lock failed: storage %s for sanlock leases", vg->name, lv_name, problem);
+		return 0;
+	}
+
 	if (result < 0) {
 		log_error("LV %s/%s lock failed: error %d", vg->name, lv_name, result);
 		return 0;
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index b0edeae..64b3ce9 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -17,8 +17,7 @@
 #define LOCKD_SANLOCK_LV_NAME "lvmlock"
 
 /* lockd_gl flags */
-#define LDGL_SKIP_CACHE_VALIDATE  0x00000001
-#define LDGL_UPDATE_NAMES         0x00000002
+#define LDGL_UPDATE_NAMES         0x00000001
 
 /* lockd_lv flags */
 #define LDLV_MODE_NO_SH           0x00000001


