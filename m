From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 31 Jan 2011 15:44:10 +0100
Subject: [PATCH 1/1] Fix udev synchronization for no-locking mode
In-Reply-To: <cover.1296484980.git.zkabelac@redhat.com>
References: <cover.1296484980.git.zkabelac@redhat.com>
Message-ID: <4782409942e1848995a1f1abd3f9eb83ffb43de0.1296484980.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Instead of implicitly syncing udev operation in  clustered and
file locking code -  call  syncing directly in lock_vol when
the operation unlocks VG

Currently problem is missing implicit fs_unlock() in the no_locking code.
This is used with --sysinit on read-only filesystem.  In this case
vgchange -ay could exit before all udev nodes are properly synchronised
and may cause problems with accessing such node right after
vgchange --sysinint command is finished.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    1 -
 lib/locking/file_locking.c    |    1 -
 lib/locking/locking.c         |    4 ++++
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 3872702..6d0dee4 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -217,7 +217,6 @@ static int lock_vg(struct local_client *client)
 	if (lkid == 0)
 	    return EINVAL;
 
-	lvm_do_fs_unlock(); /* Wait for devices */
 	status = sync_unlock(lockname, lkid);
 	if (status)
 	    status = errno;
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 0c8bbed..68b0420 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -215,7 +215,6 @@ static int _lock_file(const char *file, uint32_t flags)
 		state = 'W';
 		break;
 	case LCK_UNLOCK:
-		fs_unlock(); /* Wait until devices are available */
 		return _release_lock(file, 1);
 	default:
 		log_error("Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 645f25d..c923610 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -442,6 +442,10 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 		/* If LVM1 driver knows about the VG, it can't be accessed. */
 		if (!check_lvm1_vg_inactive(cmd, vol))
 			return_0;
+
+		/* Before unlocking VG wait until devices are available. */
+		if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
+			sync_local_dev_names(cmd);
 		break;
 	case LCK_LV:
 		/* All LV locks are non-blocking. */
-- 
1.7.3.5


