From: Milan Broz <mbroz@redhat.com>
Date: Mon, 28 Dec 2009 21:21:07 +0100
Subject: [PATCH 2/4] Move processing of VG locks to separate function (similar to LV locks).
In-Reply-To: <1262031669-26458-1-git-send-email-mbroz@redhat.com>
References: <1262031669-26458-1-git-send-email-mbroz@redhat.com>
Message-ID: <1262031669-26458-2-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

And print some debugging info.

No functional change in this patch.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    9 +++------
 daemons/clvmd/lvm-functions.c |   17 ++++++++++++++---
 daemons/clvmd/lvm-functions.h |    3 ++-
 3 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 2612a0e..1f8d0cf 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -119,15 +119,12 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		break;
 
 	case CLVMD_CMD_LOCK_VG:
+		lock_cmd = args[0];
+		lock_flags = args[1];
 		lockname = &args[2];
 		/* Check to see if the VG is in use by LVM1 */
 		status = do_check_lvm1(lockname);
-		/* P_#global causes a full cache refresh */
-		if (!strcmp(lockname, "P_" VG_GLOBAL))
-			do_refresh_cache();
-		else
-			drop_metadata(lockname + 2);
-
+		do_lock_vg(lock_cmd, lock_flags, lockname);
 		break;
 
 	case CLVMD_CMD_LOCK_LV:
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index c832ec5..983f90f 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -676,12 +676,23 @@ static void drop_vg_locks()
 }
 
 /*
- * Drop lvmcache metadata
+ * Handle VG lock - drop metadata or update lvmcache state
  */
-void drop_metadata(const char *vgname)
+void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 {
-	DEBUGLOG("Dropping metadata for VG %s\n", vgname);
+	char *vgname = resource + 2;
+
+	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
+		 resource, decode_locking_cmd(command), decode_flags(lock_flags), memlock());
+
+	/* P_#global causes a full cache refresh */
+	if (!strcmp(resource, "P_" VG_GLOBAL)) {
+		do_refresh_cache();
+		return;
+	}
+
 	pthread_mutex_lock(&lvm_lock);
+	DEBUGLOG("Dropping metadata for VG %s\n", vgname);
 	lvmcache_drop_metadata(vgname);
 	pthread_mutex_unlock(&lvm_lock);
 }
diff --git a/daemons/clvmd/lvm-functions.h b/daemons/clvmd/lvm-functions.h
index 3fc3e06..8b94e69 100644
--- a/daemons/clvmd/lvm-functions.h
+++ b/daemons/clvmd/lvm-functions.h
@@ -35,6 +35,7 @@ extern void lvm_do_backup(const char *vgname);
 extern int hold_unlock(char *resource);
 extern int hold_lock(char *resource, int mode, int flags);
 extern char *get_last_lvm_error(void);
-extern void drop_metadata(const char *vgname);
+extern void do_lock_vg(unsigned char command, unsigned char lock_flags,
+		      char *resource);
 
 #endif
-- 
1.6.5.7


