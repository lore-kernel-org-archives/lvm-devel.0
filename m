From: Milan Broz <mbroz@redhat.com>
Date: Fri,  4 Jun 2010 17:11:31 +0200
Subject: [PATCH] Clean up cluster lock mode and flags definition.
Message-ID: <1275664291-18424-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Code is mixing up internal DLM and LVM definitions of lock
modes and flags.

OpenAIS and singlenode locking do not depend on DLM but
code currently cannot be compiled without libdlm.h!

LCK_* flags is LVM abstraction, used through all the code.
Only low-level backend (clvmd-cmac etc) should use DLM definitions,
also this code should do all needed conversions.

Because there are two DLM flags used in generic code
(NOQUEUE, CONVERT) we define it similar way like lock modes.
(So all needed binary-compatible flags are on one place in locking.h)
---
 daemons/clvmd/clvmd-command.c |    5 +--
 daemons/clvmd/clvmd-gulm.c    |    2 +-
 daemons/clvmd/clvmd-gulm.h    |    4 ---
 daemons/clvmd/lvm-functions.c |   42 +++++++++++++++++++---------------------
 lib/locking/locking.h         |    6 +++++
 5 files changed, 29 insertions(+), 30 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 83d03ef..b4e8a97 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -69,7 +69,6 @@
 #include <unistd.h>
 #include <errno.h>
 #include <libdevmapper.h>
-#include <libdlm.h>
 
 #include "locking.h"
 #include "lvm-logging.h"
@@ -239,7 +238,7 @@ static int lock_vg(struct local_client *client)
 	/* Read locks need to be PR; other modes get passed through */
 	if (lock_mode == LCK_READ)
 	    lock_mode = LCK_PREAD;
-	status = sync_lock(lockname, lock_mode, (lock_cmd & LCK_NONBLOCK) ? LKF_NOQUEUE : 0, &lkid);
+	status = sync_lock(lockname, lock_mode, (lock_cmd & LCK_NONBLOCK) ? LCKF_NOQUEUE : 0, &lkid);
 	if (status)
 	    status = errno;
 	else
@@ -266,7 +265,7 @@ int do_pre_command(struct local_client *client)
 
 	switch (header->cmd) {
 	case CLVMD_CMD_TEST:
-		status = sync_lock("CLVMD_TEST", LKM_EXMODE, 0, &lockid);
+		status = sync_lock("CLVMD_TEST", LCK_EXCL, 0, &lockid);
 		client->bits.localsock.private = (void *)(long)lockid;
 		break;
 
diff --git a/daemons/clvmd/clvmd-gulm.c b/daemons/clvmd/clvmd-gulm.c
index 54dce4d..1f7977d 100644
--- a/daemons/clvmd/clvmd-gulm.c
+++ b/daemons/clvmd/clvmd-gulm.c
@@ -738,7 +738,7 @@ static int _lock_resource(char *resource, int mode, int flags, int *lockid)
     pthread_mutex_lock(&lwait.mutex);
 
     /* This needs to be converted from DLM/LVM2 value for GULM */
-    if (flags & LKF_NOQUEUE) flags = lg_lock_flag_Try;
+    if (flags & LCKF_NOQUEUE) flags = lg_lock_flag_Try;
 
     dm_hash_insert(lock_hash, resource, &lwait);
     DEBUGLOG("lock_resource '%s', flags=%d, mode=%d\n", resource, flags, mode);
diff --git a/daemons/clvmd/clvmd-gulm.h b/daemons/clvmd/clvmd-gulm.h
index d4be46f..9416f5c 100644
--- a/daemons/clvmd/clvmd-gulm.h
+++ b/daemons/clvmd/clvmd-gulm.h
@@ -1,7 +1,3 @@
-
-/* DLM constant that clvmd uses as a generic NONBLOCK lock flag */
-#define LKF_NOQUEUE 1
-
 extern int get_next_node_csid(void **context, char *csid);
 extern void add_down_node(char *csid);
 extern int gulm_fd(void);
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 5877a31..2be904b 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -35,7 +35,6 @@
 #include <syslog.h>
 #include <assert.h>
 #include <libdevmapper.h>
-#include <libdlm.h>
 
 #include "lvm-types.h"
 #include "clvm.h"
@@ -243,7 +242,7 @@ int hold_lock(char *resource, int mode, int flags)
 	struct lv_info *lvi;
 
 	/* Mask off invalid options */
-	flags &= LKF_NOQUEUE | LKF_CONVERT;
+	flags &= LCKF_NOQUEUE | LCKF_CONVERT;
 
 	lvi = lookup_info(resource);
 
@@ -253,7 +252,7 @@ int hold_lock(char *resource, int mode, int flags)
 	}
 
 	/* Only allow explicit conversions */
-	if (lvi && !(flags & LKF_CONVERT)) {
+	if (lvi && !(flags & LCKF_CONVERT)) {
 		errno = EBUSY;
 		return -1;
 	}
@@ -276,7 +275,7 @@ int hold_lock(char *resource, int mode, int flags)
 			return -1;
 
 		lvi->lock_mode = mode;
-		status = sync_lock(resource, mode, flags & ~LKF_CONVERT, &lvi->lock_id);
+		status = sync_lock(resource, mode, flags & ~LCKF_CONVERT, &lvi->lock_id);
 		saved_errno = errno;
 		if (status) {
 			free(lvi);
@@ -346,9 +345,9 @@ static int do_activate_lv(char *resource, unsigned char lock_flags, int mode)
 		return 0;	/* Success, we did nothing! */
 
 	/* Do we need to activate exclusively? */
-	if ((activate_lv == 2) || (mode == LKM_EXMODE)) {
+	if ((activate_lv == 2) || (mode == LCK_EXCL)) {
 		exclusive = 1;
-		mode = LKM_EXMODE;
+		mode = LCK_EXCL;
 	}
 
 	/*
@@ -357,7 +356,7 @@ static int do_activate_lv(char *resource, unsigned char lock_flags, int mode)
 	 * of exclusive lock to shared one during activation.
 	 */
 	if (lock_flags & LCK_CLUSTER_VG) {
-		status = hold_lock(resource, mode, LKF_NOQUEUE | (lock_flags & LCK_CONVERT?LKF_CONVERT:0));
+		status = hold_lock(resource, mode, LCKF_NOQUEUE | (lock_flags & LCK_CONVERT ? LCKF_CONVERT:0));
 		if (status) {
 			/* Return an LVM-sensible error for this.
 			 * Forcing EIO makes the upper level return this text
@@ -465,12 +464,11 @@ const char *do_lock_query(char *resource)
 
 	mode = get_current_lock(resource);
 	switch (mode) {
-		case LKM_NLMODE: type = "NL"; break;
-		case LKM_CRMODE: type = "CR"; break;
-		case LKM_CWMODE: type = "CW"; break;
-		case LKM_PRMODE: type = "PR"; break;
-		case LKM_PWMODE: type = "PW"; break;
-		case LKM_EXMODE: type = "EX"; break;
+		case LCK_NULL: type = "NL"; break;
+		case LCK_READ: type = "CR"; break;
+		case LCK_PREAD:type = "PR"; break;
+		case LCK_WRITE:type = "PW"; break;
+		case LCK_EXCL: type = "EX"; break;
 	}
 
 	DEBUGLOG("do_lock_query: resource '%s', mode %i (%s)\n", resource, mode, type ?: "?");
@@ -511,7 +509,7 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 
 	switch (command & LCK_MASK) {
 	case LCK_LV_EXCLUSIVE:
-		status = do_activate_lv(resource, lock_flags, LKM_EXMODE);
+		status = do_activate_lv(resource, lock_flags, LCK_EXCL);
 		break;
 
 	case LCK_LV_SUSPEND:
@@ -528,7 +526,7 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 		break;
 
 	case LCK_LV_ACTIVATE:
-		status = do_activate_lv(resource, lock_flags, LKM_CRMODE);
+		status = do_activate_lv(resource, lock_flags, LCK_READ);
 		break;
 
 	case LCK_LV_DEACTIVATE:
@@ -560,14 +558,14 @@ int pre_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	/* Nearly all the stuff happens cluster-wide. Apart from SUSPEND. Here we get the
 	   lock out on this node (because we are the node modifying the metadata)
 	   before suspending cluster-wide.
-	   LKF_CONVERT is used always, local node is going to modify metadata
+	   LCKF_CONVERT is used always, local node is going to modify metadata
 	 */
 	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_SUSPEND &&
 	    (lock_flags & LCK_CLUSTER_VG)) {
 		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
-		if (hold_lock(resource, LKM_PWMODE, LKF_NOQUEUE | LKF_CONVERT))
+		if (hold_lock(resource, LCK_WRITE, LCKF_NOQUEUE | LCKF_CONVERT))
 			return errno;
 	}
 	return 0;
@@ -590,7 +588,7 @@ int post_lock_lv(unsigned char command, unsigned char lock_flags,
 
 		/* If the lock state is PW then restore it to what it was */
 		oldmode = get_current_lock(resource);
-		if (oldmode == LKM_PWMODE) {
+		if (oldmode == LCK_WRITE) {
 			struct lvinfo lvi;
 
 			pthread_mutex_lock(&lvm_lock);
@@ -600,7 +598,7 @@ int post_lock_lv(unsigned char command, unsigned char lock_flags,
 				return EIO;
 
 			if (lvi.exists) {
-				if (hold_lock(resource, LKM_CRMODE, LKF_CONVERT))
+				if (hold_lock(resource, LCK_READ, LCKF_CONVERT))
 					return errno;
 			} else {
 				if (hold_unlock(resource))
@@ -792,15 +790,15 @@ static void *get_initial_state(char **argv)
 				memcpy(&uuid[58], &lv[32], 6);
 				uuid[64] = '\0';
 
-				lock_mode = LKM_CRMODE;
+				lock_mode = LCK_READ;
 
 				/* Look for this lock in the list of EX locks
 				   we were passed on the command-line */
 				if (was_ex_lock(uuid, argv))
-					lock_mode = LKM_EXMODE;
+					lock_mode = LCK_EXCL;
 
 				DEBUGLOG("getting initial lock for %s\n", uuid);
-				hold_lock(uuid, lock_mode, LKF_NOQUEUE);
+				hold_lock(uuid, lock_mode, LCKF_NOQUEUE);
 			}
 		}
 	}
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index d904cf2..488d194 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -73,6 +73,12 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_UNLOCK      0x00000006U	/* This is ours */
 
 /*
+ * Lock flags - these numbers are the same as DLM
+ */
+#define LCKF_NOQUEUE	0x00000001U	/* LKF$_NOQUEUE */
+#define LCKF_CONVERT	0x00000004U	/* LKF$_CONVERT */
+
+/*
  * Lock scope
  */
 #define LCK_SCOPE_MASK	0x00000008U
-- 
1.7.1


