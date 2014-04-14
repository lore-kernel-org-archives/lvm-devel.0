From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:07 +0000 (UTC)
Subject: master - clvmd: fix test mode race
Message-ID: <20140414110607.A616F609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91f4e09b48a2e9f909f3686c8d3a9dba274d1779
Commit:        91f4e09b48a2e9f909f3686c8d3a9dba274d1779
Parent:        bd3e44643de16ba0171af05413626a55a0a51b42
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 9 07:58:40 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 12:55:46 2014 +0200

clvmd: fix test mode race

When TEST_MODE flag is passed around the cluster,
it's been use in thread unprotected way, so it may have
influenced behaviour of other running parallel lvm commands
(activation/deactivation/suspend/resume).

Fix it by set/query function only under lvm mutex.
For hold_un/lock function calls check lock_flags bits directly.
---
 WHATS_NEW                     |    1 +
 daemons/clvmd/clvmd-command.c |   13 -------------
 daemons/clvmd/clvmd.c         |    1 -
 daemons/clvmd/lvm-functions.c |   32 ++++++++++++++++++--------------
 4 files changed, 19 insertions(+), 28 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4a35b7e..9c42344 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Fix usage of --test option in clvmd.
   Skip more libraries to be mlocked in memory.
   Remove LOCKED flag for pvmove replaced with error target.
   Return invalid command when specifying negative polling interval.
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 611f6bf..9e59e51 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -78,9 +78,6 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 	unsigned char lock_cmd;
 	unsigned char lock_flags;
 
-	/* Reset test mode before we start */
-	init_test(0);
-
 	/* Do the command */
 	switch (msg->cmd) {
 		/* Just a test message */
@@ -112,8 +109,6 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		lockname = &args[2];
 		/* Check to see if the VG is in use by LVM1 */
 		status = do_check_lvm1(lockname);
-		if (lock_flags & LCK_TEST_MODE)
-			init_test(1);
 		do_lock_vg(lock_cmd, lock_flags, lockname);
 		break;
 
@@ -122,8 +117,6 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		lock_cmd = args[0];
 		lock_flags = args[1];
 		lockname = &args[2];
-		if (lock_flags & LCK_TEST_MODE)
-			init_test(1);
 		status = do_lock_lv(lock_cmd, lock_flags, lockname);
 		/* Replace EIO with something less scary */
 		if (status == EIO) {
@@ -252,7 +245,6 @@ int do_pre_command(struct local_client *client)
 	int status = 0;
 	char *lockname;
 
-	init_test(0);
 	switch (header->cmd) {
 	case CLVMD_CMD_TEST:
 		status = sync_lock("CLVMD_TEST", LCK_EXCL, 0, &lockid);
@@ -271,8 +263,6 @@ int do_pre_command(struct local_client *client)
 		lock_cmd = args[0];
 		lock_flags = args[1];
 		lockname = &args[2];
-		if (lock_flags & LCK_TEST_MODE)
-			init_test(1);
 		status = pre_lock_lv(lock_cmd, lock_flags, lockname);
 		break;
 
@@ -304,7 +294,6 @@ int do_post_command(struct local_client *client)
 	char *args = header->node + strlen(header->node) + 1;
 	char *lockname;
 
-	init_test(0);
 	switch (header->cmd) {
 	case CLVMD_CMD_TEST:
 		status = sync_unlock("CLVMD_TEST", (int) (long) client->bits.localsock.private);
@@ -315,8 +304,6 @@ int do_post_command(struct local_client *client)
 		lock_cmd = args[0];
 		lock_flags = args[1];
 		lockname = &args[2];
-		if (lock_flags & LCK_TEST_MODE)
-			init_test(1);
 		status = post_lock_lv(lock_cmd, lock_flags, lockname);
 		break;
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index bc98ccb..0ad0c3a 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1762,7 +1762,6 @@ static int process_local_command(struct clvm_header *msg, int msglen,
 	if (msg->flags & CLVMD_FLAG_REMOTE)
 		status = 0;
 	else
-		/* FIXME: usage of init_test() is unprotected */
 		status = do_command(client, msg, msglen, &replybuf, buflen, &replylen);
 
 	if (status)
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index f4fb7fd..2ecf7d7 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -251,9 +251,6 @@ static int hold_lock(char *resource, int mode, int flags)
 	int saved_errno;
 	struct lv_info *lvi;
 
-	if (test_mode())
-		return 0;
-
 	/* Mask off invalid options */
 	flags &= LCKF_NOQUEUE | LCKF_CONVERT;
 
@@ -319,9 +316,6 @@ static int hold_unlock(char *resource)
 	int status;
 	int saved_errno;
 
-	if (test_mode())
-		return 0;
-
 	if (!(lvi = lookup_info(resource))) {
 		DEBUGLOG("hold_unlock, lock not already held\n");
 		return 0;
@@ -381,7 +375,7 @@ static int do_activate_lv(char *resource, unsigned char command, unsigned char l
 	 * Use lock conversion only if requested, to prevent implicit conversion
 	 * of exclusive lock to shared one during activation.
 	 */
-	if (command & LCK_CLUSTER_VG) {
+	if (!test_mode() && command & LCK_CLUSTER_VG) {
 		status = hold_lock(resource, mode, LCKF_NOQUEUE | (lock_flags & LCK_CONVERT ? LCKF_CONVERT:0));
 		if (status) {
 			/* Return an LVM-sensible error for this.
@@ -415,7 +409,7 @@ static int do_activate_lv(char *resource, unsigned char command, unsigned char l
 	return 0;
 
 error:
-	if (oldmode == -1 || oldmode != mode)
+	if (!test_mode() && (oldmode == -1 || oldmode != mode))
 		(void)hold_unlock(resource);
 	return EIO;
 }
@@ -479,7 +473,7 @@ static int do_deactivate_lv(char *resource, unsigned char command, unsigned char
 	if (!lv_deactivate(cmd, resource, NULL))
 		return EIO;
 
-	if (command & LCK_CLUSTER_VG) {
+	if (!test_mode() && command & LCK_CLUSTER_VG) {
 		status = hold_unlock(resource);
 		if (status)
 			return errno;
@@ -526,6 +520,8 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	}
 
 	pthread_mutex_lock(&lvm_lock);
+	init_test((lock_flags & LCK_TEST_MODE) ? 1 : 0);
+
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(1);
 
@@ -578,6 +574,7 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 
 	/* clean the pool for another command */
 	dm_pool_empty(cmd->mem);
+	init_test(0);
 	pthread_mutex_unlock(&lvm_lock);
 
 	DEBUGLOG("Command return is %d, critical_section is %d\n", status, critical_section());
@@ -597,7 +594,8 @@ int pre_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
-		if (hold_lock(resource, LCK_WRITE, LCKF_NOQUEUE | LCKF_CONVERT))
+		if (!(lock_flags & LCK_TEST_MODE) &&
+		    hold_lock(resource, LCK_WRITE, LCKF_NOQUEUE | LCKF_CONVERT))
 			return errno;
 	}
 	return 0;
@@ -629,11 +627,13 @@ int post_lock_lv(unsigned char command, unsigned char lock_flags,
 			if (!status)
 				return EIO;
 
-			if (lvi.exists) {
-				if (hold_lock(resource, LCK_READ, LCKF_CONVERT))
+			if (!(lock_flags & LCK_TEST_MODE)) {
+				if (lvi.exists) {
+					if (hold_lock(resource, LCK_READ, LCKF_CONVERT))
+						return errno;
+				} else if (hold_unlock(resource))
 					return errno;
-			} else if (hold_unlock(resource))
-				return errno;
+			}
 		}
 	}
 	return 0;
@@ -697,6 +697,8 @@ void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 	}
 
 	pthread_mutex_lock(&lvm_lock);
+	init_test((lock_flags & LCK_TEST_MODE) ? 1 : 0);
+
 	switch (lock_cmd) {
 		case LCK_VG_COMMIT:
 			DEBUGLOG("vg_commit notification for VG %s\n", vgname);
@@ -711,6 +713,8 @@ void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 			DEBUGLOG("Invalidating cached metadata for VG %s\n", vgname);
 			lvmcache_drop_metadata(vgname, 0);
 	}
+
+	init_test(0);
 	pthread_mutex_unlock(&lvm_lock);
 }
 


