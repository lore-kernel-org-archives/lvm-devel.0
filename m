From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Sep 2014 13:57:40 +0000 (UTC)
Subject: master - lvchange: backup final metadata
Message-ID: <20140919135740.C020560CD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3adc50ac22f5a3e355db5d143303c8b7dfb7c828
Commit:        3adc50ac22f5a3e355db5d143303c8b7dfb7c828
Parent:        f09f85d027d8833727483efd6077f52d2e5b6ba2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 15:16:26 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 15:55:34 2014 +0200

lvchange: backup final metadata

Shift backup after final metadata commit.

Synchronize with wiping.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a2c4577..c5ba9fa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Backup final metadata after resync of mirror/raid.
   Unify handling of --persistent option for lvcreate and lvchange.
   Validate major and minor numbers stored in metadata.
   Use -fPIE when linking -pie executables.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 8ccbe19..b196591 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+#include "memlock.h"
 
 static int lvchange_permission(struct cmd_context *cmd,
 			       struct logical_volume *lv)
@@ -416,7 +417,8 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
-	backup(lv->vg);
+	/* No backup for intermediate metadata, so just unlock memory */
+	memlock_unlock(lv->vg->cmd);
 
 	dm_list_iterate_items(lvl, &device_list) {
 		if (!activate_lv_excl_local(cmd, lvl->lv)) {
@@ -449,6 +451,8 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		}
 	}
 
+	sync_local_dev_names(lv->vg->cmd);  /* Wait until devices are away */
+
 	/* Put metadata sub-LVs back in place */
 	if (!attach_metadata_devices(seg, &device_list)) {
 		log_error("Failed to reattach %s device after clearing",
@@ -463,11 +467,14 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	}
 
 	if (!_reactivate_lv(lv, active, exclusive)) {
+		backup(lv->vg);
 		log_error("Failed to reactivate %s after resync",
 			  lv->name);
 		return 0;
 	}
 
+	backup(lv->vg);
+
 	return 1;
 }
 


