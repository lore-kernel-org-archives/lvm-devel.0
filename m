From: Milan Broz <mbroz@redhat.com>
Date: Mon, 28 Dec 2009 21:21:09 +0100
Subject: [PATCH 4/4] Propagate commit and revert metadata event to other nodes in cluster.
In-Reply-To: <1262031669-26458-1-git-send-email-mbroz@redhat.com>
References: <1262031669-26458-1-git-send-email-mbroz@redhat.com>
Message-ID: <1262031669-26458-4-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch tries to corectly track changes in lvmcache related to commit/revert.

For vg_commit: if there are cached precommitted metadata, after successfull commit
these metadata must be tracked as committed.

For vg_revert: remote nodes must drop precommitted metadata and its flag in lvmcache.

Because of current clvmd protocol limitation (unsigned char) there are some non-obvious
hacks used.

 - The LCK_CACHE bit is translated to another "optional" flag (because we are out of lock flags)
 - The LOCK_HOLD (which is normally unused in VG locks) is used in commit/revert message

Also patch removes LCK_TYPES_MASKing which currently prevents these flas to be send
to remote nodes.

(N.B. Patch do not touch LV locks here in any way.)

All this machinery is needed to properly solve remote node cache invalidaton which
cause several problems recently observed.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/lvm-functions.c |   25 ++++++++++++++++++++++---
 lib/locking/cluster_locking.c |    4 +++-
 lib/locking/locking.h         |   12 ++++++++++++
 lib/metadata/metadata.c       |    8 ++++++++
 4 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index ad6b924..d7a3a18 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -145,10 +145,11 @@ static const char *decode_flags(unsigned char flags)
 {
 	static char buf[128];
 
-	sprintf(buf, "0x%x (%s%s%s%s)", flags,
+	sprintf(buf, "0x%x (%s%s%s%s%s)", flags,
 		flags & LCK_PARTIAL_MODE	  ? "PARTIAL_MODE " : "",
 		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC " : "",
 		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR " : "",
+		flags & LCK_VG_CACHE ? "CACHE " : "",
 		flags & LCK_CONVERT ? "CONVERT " : "");
 
 	return buf;
@@ -680,6 +681,7 @@ static void drop_vg_locks()
  */
 void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 {
+	uint32_t lock_cmd = command;
 	char *vgname = resource + 2;
 
 	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
@@ -691,9 +693,26 @@ void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 		return;
 	}
 
+	/* Decode command back... */
+	lock_cmd &= (LCK_SCOPE_MASK | LCK_TYPE_MASK | LCK_HOLD);
+	if (lock_flags & LCK_VG_CACHE)
+		lock_cmd |= LCK_CACHE;
+
 	pthread_mutex_lock(&lvm_lock);
-	DEBUGLOG("Dropping metadata for VG %s\n", vgname);
-	lvmcache_drop_metadata(vgname, 0);
+	switch (lock_cmd) {
+		case LCK_VG_COMMIT:
+			DEBUGLOG("vg_commit notification for VG %s\n", vgname);
+			lvmcache_commit_metadata(vgname);
+			break;
+		case LCK_VG_REVERT:
+			DEBUGLOG("vg_revert notification for VG %s\n", vgname);
+			lvmcache_drop_metadata(vgname, 1);
+			break;
+		case LCK_VG_DROP_CACHE:
+		default:
+			DEBUGLOG("Dropping metadata for VG %s\n", vgname);
+			lvmcache_drop_metadata(vgname, 0);
+	}
 	pthread_mutex_unlock(&lvm_lock);
 }
 
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 225795a..cf858be 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -330,6 +330,9 @@ static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
 	if (cmd->partial_activation)
 		args[1] |= LCK_PARTIAL_MODE;
 
+	if (flags & LCK_CACHE)
+		args[1] |= LCK_VG_CACHE;
+
 	/*
 	 * VG locks are just that: locks, and have no side effects
 	 * so we only need to do them on the local node because all
@@ -409,7 +412,6 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 
 		lock_scope = "VG";
 		clvmd_cmd = CLVMD_CMD_LOCK_VG;
-		flags &= LCK_TYPE_MASK;
 		break;
 
 	case LCK_LV:
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 50101d1..75325e7 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -82,6 +82,8 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_HOLD	0x00000020U	/* Hold lock when lock_vol returns? */
 #define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
 #define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
+/* FIXME: only lowest 8bits send in cluster locking,
+ * in remote node LCK_VG_CACHE is set instead*/
 #define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
 
 /*
@@ -91,6 +93,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_MIRROR_NOSYNC_MODE	0x00000002U	/* Mirrors don't require sync */
 #define LCK_DMEVENTD_MONITOR_MODE	0x00000004U	/* Register with dmeventd */
 #define LCK_CONVERT		0x00000008U	/* Convert existing lock */
+#define LCK_VG_CACHE		0x00000010U	/* set when LCK_CACHE is set */
 
 /*
  * Special cases of VG locks.
@@ -107,6 +110,11 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
 #define LCK_VG_DROP_CACHE	(LCK_VG | LCK_WRITE | LCK_CACHE)
+
+/* FIXME: LCK_HOLD abused here */
+#define LCK_VG_COMMIT		(LCK_VG | LCK_WRITE | LCK_CACHE | LCK_HOLD)
+#define LCK_VG_REVERT		(LCK_VG | LCK_READ  | LCK_CACHE | LCK_HOLD)
+
 #define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
 
 #define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL)
@@ -142,6 +150,10 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
 #define drop_cached_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE)
+#define remote_commit_cached_metadata(vg)	\
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_COMMIT)
+#define remote_revert_cached_metadata(vg)	\
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT)
 #define remote_backup_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c24bbda..1baa4b6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2331,6 +2331,12 @@ int vg_commit(struct volume_group *vg)
 		}
 	}
 
+	/*
+	 * Inform that remote nodes so the can drop precommited-only flag.
+	 */
+	if (cache_updated)
+		remote_commit_cached_metadata(vg);
+
 	/* If update failed, remove any cached precommitted metadata. */
 	if (!cache_updated && !drop_cached_metadata(vg))
 		log_error("Attempt to drop cached metadata failed "
@@ -2356,6 +2362,8 @@ int vg_revert(struct volume_group *vg)
 		log_error("Attempt to drop cached metadata failed "
 			  "after reverted update for VG %s.", vg->name);
 
+	remote_revert_cached_metadata(vg);
+
 	return 1;
 }
 
-- 
1.6.5.7


