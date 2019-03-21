From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Mar 2019 13:46:15 -0400
Subject: master - lvextend: allow on LV active with a shared lock
Message-ID: <201903211746.x2LHkF0D030621@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d369de8399e14e82fb1ea45e7977d917411fbc21
Commit:        d369de8399e14e82fb1ea45e7977d917411fbc21
Parent:        9b4926aaff7f8644c8492cd68ab0b7079416ef3a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 19 14:38:38 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 21 12:38:20 2019 -0500

lvextend: allow on LV active with a shared lock

Detect when a shared lock exists, don't require the
normal exclusive lock, and allow the lvextend.
---
 daemons/lvmlockd/lvmlockd-core.c     |    5 ++++-
 daemons/lvmlockd/lvmlockd-internal.h |    1 +
 lib/locking/lvmlockd.c               |   17 +++++++++++++++++
 lib/locking/lvmlockd.h               |    2 ++
 lib/metadata/lv_manip.c              |    2 +-
 5 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 40a2f21..da3de54 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1816,9 +1816,9 @@ static void res_process(struct lockspace *ls, struct resource *r,
 			add_client_result(act);
 		} else {
 			/* persistent lock is sh, transient request is ex */
-			/* FIXME: can we remove this case? do a convert here? */
 			log_debug("res_process %s existing persistent lock new transient", r->name);
 			r->last_client_id = act->client_id;
+			act->flags |= LD_AF_SH_EXISTS;
 			act->result = -EEXIST;
 			list_del(&act->list);
 			add_client_result(act);
@@ -3661,6 +3661,9 @@ static int client_send_result(struct client *cl, struct action *act)
 	if ((act->flags & LD_AF_WARN_GL_REMOVED) || gl_vg_removed)
 		strcat(result_flags, "WARN_GL_REMOVED,");
 	
+	if (act->flags & LD_AF_SH_EXISTS)
+		strcat(result_flags, "SH_EXISTS,");
+
 	if (act->op == LD_OP_INIT) {
 		/*
 		 * init is a special case where lock args need
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index f0fa85f..50015f1 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -106,6 +106,7 @@ struct client {
 #define LD_AF_WARN_GL_REMOVED	   0x00020000
 #define LD_AF_LV_LOCK              0x00040000
 #define LD_AF_LV_UNLOCK            0x00080000
+#define LD_AF_SH_EXISTS            0x00100000
 
 /*
  * Number of times to repeat a lock request after
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index a143689..bc6e66f 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -118,6 +118,9 @@ static void _flags_str_to_lockd_flags(const char *flags_str, uint32_t *lockd_fla
 
 	if (strstr(flags_str, "WARN_GL_REMOVED"))
 		*lockd_flags |= LD_RF_WARN_GL_REMOVED;
+
+	if (strstr(flags_str, "SH_EXISTS"))
+		*lockd_flags |= LD_RF_SH_EXISTS;
 }
 
 /*
@@ -2205,6 +2208,20 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		 * LV with an ex LV lock when the LV is already active with a
 		 * sh LV lock.
 		 */
+
+		/*
+		 * Special case to allow lvextend under gfs2.
+		 *
+		 * FIXME: verify the LV actually holds gfs2/ocfs2 which we know
+		 * allow this (other users of the LV may not.)
+		 */
+		if (lockd_flags & LD_RF_SH_EXISTS) {
+			if (flags & LDLV_EXTEND) {
+				log_warn("WARNING: extending LV with a shared lock, other hosts may require LV refresh.");
+				return 1;
+			}
+		}
+
 		log_error("LV is already locked with incompatible mode: %s/%s", vg->name, lv_name);
 		return 0;
 	}
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index e5ae331..53d077e 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -22,6 +22,7 @@
 /* lockd_lv flags */
 #define LDLV_MODE_NO_SH           0x00000001
 #define LDLV_PERSISTENT           0x00000002
+#define LDLV_EXTEND               0x00000004
 
 /* lvmlockd result flags */
 #define LD_RF_NO_LOCKSPACES     0x00000001
@@ -29,6 +30,7 @@
 #define LD_RF_WARN_GL_REMOVED   0x00000004
 #define LD_RF_DUP_GL_LS         0x00000008
 #define LD_RF_NO_LM		0x00000010
+#define LD_RF_SH_EXISTS		0x00000020
 
 /* lockd_state flags */
 #define LDST_EX			0x00000001
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e128336..c21a0f9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5762,7 +5762,7 @@ int lv_resize(struct logical_volume *lv,
 	 * If the LV is locked from activation, this lock call is a no-op.
 	 * Otherwise, this acquires a transient lock on the lv (not PERSISTENT).
 	 */
-	if (!lockd_lv(cmd, lock_lv, "ex", 0))
+	if (!lockd_lv(cmd, lock_lv, "ex", (lp->resize == LV_EXTEND) ? LDLV_EXTEND : 0))
 		return_0;
 
 	if (!archive(vg))


