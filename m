From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:56:21 +0100
Subject: [PATCH 3/3] Add fs_unlock calls
In-Reply-To: <cover.1292496056.git.zkabelac@redhat.com>
References: <cover.1292496056.git.zkabelac@redhat.com>
Message-ID: <e0a34706b95b7077e7d0db90c1cace819ac2c70f.1292496056.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add lvm_do_unlock_fs()

Call fs_unlock() when unlocking vg where implicit unlock solves the
problem also for cluster - thus no extra command for clustering
environment is required - only lvm_do_unlock_fs() function is add
to call lvm's fs_unlock() while holding lvm_lock mutex in clvmd.

Add fs_unlock() also to set_lv() so the system waits until device
is ready for regular open (usully wiping device begining).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    1 +
 daemons/clvmd/lvm-functions.c |    8 ++++++++
 daemons/clvmd/lvm-functions.h |    1 +
 include/.symlinks.in          |    1 +
 lib/locking/file_locking.c    |    2 ++
 lib/metadata/lv_manip.c       |    4 ++++
 6 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 915fcc7..4c3e704 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -214,6 +214,7 @@ static int lock_vg(struct local_client *client)
 	if (lkid == 0)
 	    return EINVAL;
 
+	lvm_do_unlock_fs(); /* Wait for devices */
 	status = sync_unlock(lockname, lkid);
 	if (status)
 	    status = errno;
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 214f229..dcdad6b 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -30,6 +30,7 @@
 #include "activate.h"
 #include "archiver.h"
 #include "memlock.h"
+#include "fs.h"
 
 #include <syslog.h>
 
@@ -894,6 +895,13 @@ struct dm_hash_node *get_next_excl_lock(struct dm_hash_node *v, char **name)
 	return v;
 }
 
+void lvm_do_unlock_fs(void)
+{
+	pthread_mutex_lock(&lvm_lock);
+	fs_unlock();
+	pthread_mutex_unlock(&lvm_lock);
+}
+
 /* Called to initialise the LVM context of the daemon */
 int init_clvm(int using_gulm, char **argv)
 {
diff --git a/daemons/clvmd/lvm-functions.h b/daemons/clvmd/lvm-functions.h
index 97153d4..6558863 100644
--- a/daemons/clvmd/lvm-functions.h
+++ b/daemons/clvmd/lvm-functions.h
@@ -36,5 +36,6 @@ extern char *get_last_lvm_error(void);
 extern void do_lock_vg(unsigned char command, unsigned char lock_flags,
 		      char *resource);
 extern struct dm_hash_node *get_next_excl_lock(struct dm_hash_node *v, char **name);
+void lvm_do_unlock_fs(void);
 
 #endif
diff --git a/include/.symlinks.in b/include/.symlinks.in
index c16e107..263c530 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -2,6 +2,7 @@
 @top_srcdir@/daemons/dmeventd/libdevmapper-event.h
 @top_srcdir@/liblvm/lvm2app.h
 @top_srcdir@/lib/activate/activate.h
+ at top_srcdir@/lib/activate/fs.h
 @top_srcdir@/lib/activate/targets.h
 @top_srcdir@/lib/cache/lvmcache.h
 @top_srcdir@/lib/commands/errors.h
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 9137a30..7538626 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -22,6 +22,7 @@
 #include "lvm-file.h"
 #include "lvm-string.h"
 #include "lvmcache.h"
+#include "fs.h"
 
 #include <limits.h>
 #include <unistd.h>
@@ -215,6 +216,7 @@ static int _lock_file(const char *file, uint32_t flags)
 		state = 'W';
 		break;
 	case LCK_UNLOCK:
+		fs_unlock();
 		return _release_lock(file, 1);
 	default:
 		log_error("Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6f553cd..0de4ec3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -26,6 +26,7 @@
 #include "archiver.h"
 #include "activate.h"
 #include "str_list.h"
+#include "fs.h"
 
 struct lv_names {
 	const char *old;
@@ -3017,6 +3018,9 @@ int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	/* Wait until devices are available */
+	fs_unlock();
+
 	log_verbose("Clearing start of logical volume \"%s\"", lv->name);
 
 	if (!(dev = dev_cache_get(name, NULL))) {
-- 
1.7.3.3


