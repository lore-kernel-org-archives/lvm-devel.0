From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Feb 2011 14:07:57 +0100
Subject: [PATCH 1/5] Fix clustered and no-lock locking with HOTFIX
In-Reply-To: <cover.1296651808.git.zkabelac@redhat.com>
References: <cover.1296651808.git.zkabelac@redhat.com>
Message-ID: <778ee0a03898746141d905f2b9100bb6d665d09d.1296651808.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch is fixing clustered locking - but currently cluster wide
message passing does not work with sync_dev_names().

To avoid any udev synchronizaiton problems with leaving unrelased
udev cookies, revert to the old slow behavior - and check for udev
cookie with after every activate and deactivate operation inside
do_lock_vol().

Once the new message will pass around the cluster - these extra fs_unlock()
shall be removed.

The problem I have now:

Cluster does not pass any message around cluster related to unlock_vg.
So the initial idea to use this point for fs_unlock() works only on
the local/single node.

For the real multinode cluster we need to pass extra message around
 - but currently I've not managed to pass this new message around.
We cannot reuse any other message like DROP_CACHE or VG_BACKUP
as this are send when MDA is modifed - however activation does not
modify anything - yet it needs to flush udev cookie.

sync_local_dev_names() - serves for local cluster synchronization
sync_dev_names() - is supposed to be send to all nodes in cluster to
sychronizes its dev nodes. This should happen when vg is unlocked.

For this - macro 'unlock_vg()' is modifed to call sync_dev_names for
clustered locking before it actually releases VG lock - it's called
before lock_vol code to avoid recusion.

Mornfal expressed concerns about possibility to unlock VG by plain
call of lock_vol() with right parameters - this would miss the
sync call - however I'm currently not seeing better way, how
to achieve message passing around - unless we find the way to
to pass send this message within  clvmd  unlock_vg processing - the
code is currently not very clear in this area.

So once we figure out, how to pass such parameter - we may add
implicit  sync_dev_names() into unlock clvmd code and  no-locking
code.

For filesystem and external locking implicit  fs_unlock() is called
with lock_vol as there is no recursive rick in this case.

For sync names - new LCK is defined:
LCK_VG_SYNC - which should differ from LCK_VG_BACKUP by LCK_HOLD bit.
But somehow I fail to see the reason why this message is not send
around the cluster and only local node is processing this message.

Difference between local & global sync is LCL_LOCAL and  usage of
VG_SYNC_NAMES for local message.

As a potential solution could be - to overload DROP_CACHE
and with special paramater use this for as VG_SYNC_NAMES

So the cache would be dropped in other cases.
But my head already spins quite a lot around....
So any help would be appreciated.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    5 ++++-
 daemons/clvmd/clvmd.c         |    3 +++
 daemons/clvmd/lvm-functions.c |    9 +++++++--
 daemons/clvmd/lvm-functions.h |    2 +-
 lib/locking/cluster_locking.c |    6 +++---
 lib/locking/locking.c         |    7 ++++---
 lib/locking/locking.h         |   22 ++++++++++++++++++++--
 7 files changed, 42 insertions(+), 12 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 6d0dee4..c2bddc2 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -139,7 +139,10 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		break;
 
 	case CLVMD_CMD_SYNC_NAMES:
-		lvm_do_fs_unlock();
+		lock_cmd = args[0];
+		lock_flags = args[1];
+		lockname = &args[2];
+		lvm_do_fs_unlock(lock_cmd, lock_flags, lockname, client ? 1 : 0);
 		break;
 
 	case CLVMD_CMD_SET_DEBUG:
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 8e21732..f38894c 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -296,6 +296,9 @@ static const char *decode_cmd(unsigned char cmdl)
 	case CLVMD_CMD_RESTART:
 		command = "RESTART";
 		break;
+	case CLVMD_CMD_SYNC_NAMES:
+		command = "SYNC_NAMES";
+		break;
 	default:
 		command = "unknown";
 		break;
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index f06657d..8dc200e 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -507,6 +507,7 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	switch (command & LCK_MASK) {
 	case LCK_LV_EXCLUSIVE:
 		status = do_activate_lv(resource, lock_flags, LCK_EXCL);
+		fs_unlock();
 		break;
 
 	case LCK_LV_SUSPEND:
@@ -520,10 +521,12 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 
 	case LCK_LV_ACTIVATE:
 		status = do_activate_lv(resource, lock_flags, LCK_READ);
+		fs_unlock();
 		break;
 
 	case LCK_LV_DEACTIVATE:
 		status = do_deactivate_lv(resource, lock_flags);
+		fs_unlock();
 		break;
 
 	default:
@@ -894,11 +897,13 @@ struct dm_hash_node *get_next_excl_lock(struct dm_hash_node *v, char **name)
 	return v;
 }
 
-void lvm_do_fs_unlock(void)
+void lvm_do_fs_unlock(int lock_cmd, int lock_flags, char *lockname, int is_client)
 {
 	pthread_mutex_lock(&lvm_lock);
-	DEBUGLOG("Syncing device names\n");
+	DEBUGLOG("Syncing device names cmd=%d  flags=%d  name=%s client=%d\n",
+		 lock_cmd, lock_flags, lockname, is_client);
 	fs_unlock();
+
 	pthread_mutex_unlock(&lvm_lock);
 }
 
diff --git a/daemons/clvmd/lvm-functions.h b/daemons/clvmd/lvm-functions.h
index a132f4a..1b60c4f 100644
--- a/daemons/clvmd/lvm-functions.h
+++ b/daemons/clvmd/lvm-functions.h
@@ -36,6 +36,6 @@ extern char *get_last_lvm_error(void);
 extern void do_lock_vg(unsigned char command, unsigned char lock_flags,
 		      char *resource);
 extern struct dm_hash_node *get_next_excl_lock(struct dm_hash_node *v, char **name);
-void lvm_do_fs_unlock(void);
+void lvm_do_fs_unlock(int lock_cmd, int lock_flags, char *lockname, int is_client);
 
 #endif
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 83b1cd2..cecd52d 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -401,10 +401,10 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
-		if (!strcmp(resource, VG_SYNC_NAMES)) {
-			log_very_verbose("Requesting sync names.");
+		if ((flags & ~LCK_LOCAL) == LCK_VG_SYNC) {
+			log_very_verbose("Requesting sync names for %s.", resource);
 			return _lock_for_cluster(cmd, CLVMD_CMD_SYNC_NAMES,
-						 flags & ~LCK_HOLD, resource);
+						 flags, resource);
 		}
 		if (flags == LCK_VG_BACKUP) {
 			log_very_verbose("Requesting backup of VG metadata for %s",
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index c923610..a12db52 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -443,9 +443,10 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 		if (!check_lvm1_vg_inactive(cmd, vol))
 			return_0;
 
-		/* Before unlocking VG wait until devices are available. */
-		if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
-			sync_local_dev_names(cmd);
+		/* For non clustered unlock - implicit fs_unlock() */
+		if ((lck_type == LCK_UNLOCK) && !(flags & LCK_CACHE) &&
+		    is_real_vg(vol) && !locking_is_clustered())
+			fs_unlock();
 		break;
 	case LCK_LV:
 		/* All LV locks are non-blocking. */
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 1b5e1fc..122d2fc 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -126,6 +126,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_VG_REVERT		(LCK_VG | LCK_READ  | LCK_CACHE | LCK_HOLD)
 
 #define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
+#define LCK_VG_SYNC		(LCK_VG | LCK_CACHE | LCK_HOLD)
 
 #define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL)
 #define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE)
@@ -143,7 +144,20 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 		lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv)) : \
 		0)
 
-#define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
+/*
+ * For clustered locking (cluster, no_lock) explicit call
+ * of cluster wide sync_dev_names() is made before unlocking vg.
+ * For non-clustered locking (filesystem, external)
+ * use of fs_unlock() is implicit in lock_vol().
+ */
+#define unlock_vg(cmd, vol) \
+	do { \
+		if (is_real_vg(vol) && \
+		    locking_is_clustered()) \
+			sync_dev_names(cmd, vol); \
+		lock_vol(cmd, vol, LCK_VG_UNLOCK); \
+	} while (0)
+
 #define unlock_and_free_vg(cmd, vg, vol) \
 	do { \
 		unlock_vg(cmd, vol); \
@@ -170,8 +184,12 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT)
 #define remote_backup_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
+/* Synchronize local device names on cluster node */
 #define sync_local_dev_names(cmd)	\
-	lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE | LCK_LOCAL)
+	lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC | LCK_LOCAL)
+/* Synchronize global device names on all cluster nodes */
+#define sync_dev_names(cmd, vol)	\
+	lock_vol(cmd, vol, LCK_VG_SYNC)
 
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);
-- 
1.7.3.5


