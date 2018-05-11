From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 May 2018 15:38:50 -0400
Subject: master - dev_cache: remove the lvmcache check when closing fd
Message-ID: <201805111938.w4BJcokI002976@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73578e36faa78c616716617a83083cc3a31ba03f
Commit:        73578e36faa78c616716617a83083cc3a31ba03f
Parent:        3e3cb22f2a115f71f883a75c7840ab271bd83454
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 11 14:28:46 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 11 14:30:10 2018 -0500

dev_cache: remove the lvmcache check when closing fd

This is no longer used since devices are not held
open in dev_cache.
---
 lib/cache/lvmcache.c |    9 ---------
 lib/cache/lvmcache.h |    1 -
 lib/device/dev-io.c  |    5 +----
 3 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 4062faa..d45385b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2456,15 +2456,6 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	}
 }
 
-int lvmcache_pvid_is_locked(const char *pvid) {
-	struct lvmcache_info *info;
-	info = lvmcache_info_from_pvid(pvid, NULL, 0);
-	if (!info || !info->vginfo)
-		return 0;
-
-	return lvmcache_vgname_is_locked(info->vginfo->vgname);
-}
-
 int lvmcache_fid_add_mdas(struct lvmcache_info *info, struct format_instance *fid,
 			  const char *id, int id_len)
 {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 797ff21..a2a7f07 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -132,7 +132,6 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
 void lvmcache_commit_metadata(const char *vgname);
 
-int lvmcache_pvid_is_locked(const char *pvid);
 int lvmcache_fid_add_mdas(struct lvmcache_info *info, struct format_instance *fid,
 			  const char *id, int id_len);
 int lvmcache_fid_add_mdas_pv(struct lvmcache_info *info, struct format_instance *fid);
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 3a39ae5..9a03d3a 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -16,7 +16,6 @@
 #include "lib.h"
 #include "device.h"
 #include "metadata.h"
-#include "lvmcache.h"
 #include "memlock.h"
 #include "locking.h"
 
@@ -674,9 +673,7 @@ static int _dev_close(struct device *dev, int immediate)
 		log_debug_devs("%s: Immediate close attempt while still referenced",
 			       dev_name(dev));
 
-	/* Close unless device is known to belong to a locked VG */
-	if (immediate ||
-	    (dev->open_count < 1 && !lvmcache_pvid_is_locked(dev->pvid)))
+	if (immediate || (dev->open_count < 1))
 		_close(dev);
 
 	return 1;


