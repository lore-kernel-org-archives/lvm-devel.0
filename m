From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  8 Dec 2010 13:57:48 +0100
Subject: [PATCH 2/9] Move fs_unlock
In-Reply-To: <cover.1291802397.git.zkabelac@redhat.com>
References: <cover.1291802397.git.zkabelac@redhat.com>
Message-ID: <0ef19128f2913ff4c84b4721294eff53fb6858b2.1291802397.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Make fs_unlock() easily linkable function for clvmd code.
Move it for now to active.h -  maybe some better function name
is needed.

fs_unlock() is executing update_devs() -> hidden wait on semaphore.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.h |    2 ++
 lib/activate/fs.c       |    1 +
 lib/activate/fs.h       |    1 -
 3 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index df46ac2..329893d 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -101,6 +101,8 @@ int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 			   unsigned origin_only, int do_reg);
 
+void fs_unlock(void);
+
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
 char *get_monitor_dso_path(struct cmd_context *cmd, const char *libpath);
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index b78da11..a169ab0 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "fs.h"
+#include "activate.h"
 #include "toolcontext.h"
 #include "lvm-string.h"
 #include "lvm-file.h"
diff --git a/lib/activate/fs.h b/lib/activate/fs.h
index 28b2c73..640ce9a 100644
--- a/lib/activate/fs.h
+++ b/lib/activate/fs.h
@@ -29,6 +29,5 @@ int fs_del_lv_byname(const char *dev_dir, const char *vg_name,
 		     const char *lv_name, int check_udev);
 int fs_rename_lv(struct logical_volume *lv, const char *dev, 
 		 const char *old_vgname, const char *old_lvname);
-void fs_unlock(void);
 
 #endif
-- 
1.7.3.3


