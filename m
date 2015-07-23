From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 23 Jul 2015 15:39:26 +0000 (UTC)
Subject: master - lvmlockd: improve check for duplicate global locks
Message-ID: <20150723153926.304206036D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57534733b7750f17f5ffa115306dcb650d8015b9
Commit:        57534733b7750f17f5ffa115306dcb650d8015b9
Parent:        1612c570b6412b68349b055ba3a6dab1796b8f35
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 23 10:34:24 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 23 10:39:11 2015 -0500

lvmlockd: improve check for duplicate global locks

When there are duplicate global locks, check if the gl
is still enabled each time a gl or vg lock is acquired
in the lockspace.  Once one of the duplicates is disabled,
then other hosts will recognize that the issue is resolved
without needing to restart the lockspaces.
---
 daemons/lvmlockd/lvmlockd-core.c     |   23 +++++------------------
 daemons/lvmlockd/lvmlockd-internal.h |   11 +++++++++++
 daemons/lvmlockd/lvmlockd-sanlock.c  |   10 ++++++++--
 3 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index a01c8a6..7375d9e 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -199,17 +199,6 @@ static struct list_head lockspaces;
 static struct list_head lockspaces_inactive;
 
 /*
- * This flag is set to 1 if we see multiple vgs with the global
- * lock enabled.  While this is set, we return a special flag
- * with the vg lock result indicating to the lvm command that
- * there is a duplicate gl in the vg which should be resolved.
- * While this is set, find_lockspace_name has the side job of
- * counting the number of lockspaces with enabled gl's so that
- * this can be set back to zero when the duplicates are disabled.
- */
-static int sanlock_gl_dup;
-
-/*
  * Client thread reads client requests and writes client results.
  */
 static pthread_t client_thread;
@@ -1046,6 +1035,9 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 	log_debug("S %s R %s res_lock lm done r_version %u",
 		  ls->name, r->name, r_version);
 
+	if (sanlock_gl_dup && ls->sanlock_gl_enabled)
+		act->flags |= LD_AF_DUP_GL_LS;
+
 	/* lm_lock() reads new r_version */
 
 	if ((r_version > r->version) || (!r->version && !r->version_zero_valid)) {
@@ -2096,9 +2088,6 @@ static void *lockspace_thread_main(void *arg_in)
 
 			act = list_first_entry(&ls->actions, struct action, list);
 
-			if (sanlock_gl_dup && ls->sanlock_gl_enabled)
-				act->flags |= LD_AF_DUP_GL_LS;
-
 			if (act->op == LD_OP_STOP) {
 				ls->thread_work = 0;
 				break;
@@ -3855,8 +3844,7 @@ static int print_lockspace(struct lockspace *ls, const char *prefix, int pos, in
 			"thread_work=%d "
 			"thread_stop=%d "
 			"thread_done=%d "
-			"sanlock_gl_enabled=%d "
-			"sanlock_gl_dup=%d\n",
+			"sanlock_gl_enabled=%d",
 			prefix,
 			ls->name,
 			ls->vg_name,
@@ -3870,8 +3858,7 @@ static int print_lockspace(struct lockspace *ls, const char *prefix, int pos, in
 			ls->thread_work ? 1 : 0,
 			ls->thread_stop ? 1 : 0,
 			ls->thread_done ? 1 : 0,
-			ls->sanlock_gl_enabled ? 1 : 0,
-			ls->sanlock_gl_dup ? 1 : 0);
+			ls->sanlock_gl_enabled ? 1 : 0);
 }
 
 static int print_action(struct action *act, const char *prefix, int pos, int len)
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 1fd7125..7bbddb4 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -322,6 +322,17 @@ EXTERN int daemon_host_id;
 EXTERN const char *daemon_host_id_file;
 EXTERN int sanlock_io_timeout;
 
+/*
+ * This flag is set to 1 if we see multiple vgs with the global
+ * lock enabled.  While this is set, we return a special flag
+ * with the vg lock result indicating to the lvm command that
+ * there is a duplicate gl in the vg which should be resolved.
+ * While this is set, find_lockspace_name has the side job of
+ * counting the number of lockspaces with enabled gl's so that
+ * this can be set back to zero when the duplicates are disabled.
+ */
+EXTERN int sanlock_gl_dup;
+
 void log_level(int level, const char *fmt, ...)  __attribute__((format(printf, 2, 3)));
 #define log_debug(fmt, args...) log_level(LOG_DEBUG, fmt, ##args)
 #define log_error(fmt, args...) log_level(LOG_ERR, fmt, ##args)
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 28dac6b..44926da 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -801,8 +801,6 @@ int lm_able_gl_sanlock(struct lockspace *ls, int enable)
 	log_debug("S %s able_gl %s", ls->name, gl_name);
 
 	ls->sanlock_gl_enabled = enable;
-	if (ls->sanlock_gl_dup && !enable)
-		ls->sanlock_gl_dup = 0;
 
 	if (enable)
 		strncpy(gl_lsname_sanlock, ls->name, MAX_NAME);
@@ -1254,6 +1252,14 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 
 	rs = &rds->rs;
 
+	/*
+	 * While there are duplicate global locks, keep checking
+	 * to see if any have been disabled.
+	 */
+	if (sanlock_gl_dup && ls->sanlock_gl_enabled &&
+	    (r->type == LD_RT_GL || r->type == LD_RT_VG))
+		ls->sanlock_gl_enabled = gl_is_enabled(ls, ls->lm_data);
+
 	if (r->type == LD_RT_LV) {
 		/*
 		 * The lv may have been removed and recreated with a new lease


