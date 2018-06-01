From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Jun 2018 15:13:37 -0400
Subject: master - build: compile fixes
Message-ID: <201806011913.w51JDbhh010800@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a1f458bb7a95b5cf71e4e8bf9d030ce739ab039
Commit:        6a1f458bb7a95b5cf71e4e8bf9d030ce739ab039
Parent:        4d19321fd36fd6bf3f6170363f51be9ab39c03a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 1 20:24:45 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 1 21:12:31 2018 +0200

build: compile fixes

---
 lib/locking/lvmlockd.c         |    2 +-
 lib/lvmpolld/lvmpolld-client.h |    2 +-
 lib/metadata/mirror.c          |    2 +-
 tools/pvmove.c                 |    2 +-
 tools/pvscan.c                 |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 103286d..21a9696 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1111,7 +1111,7 @@ int lockd_stop_vg(struct cmd_context *cmd, struct volume_group *vg)
 	int result;
 	int ret;
 
-	if (!vg_is_shared(vg)))
+	if (!vg_is_shared(vg))
 		return 1;
 	if (!_use_lvmlockd)
 		return 0;
diff --git a/lib/lvmpolld/lvmpolld-client.h b/lib/lvmpolld/lvmpolld-client.h
index 16495b6..659b11b 100644
--- a/lib/lvmpolld/lvmpolld-client.h
+++ b/lib/lvmpolld/lvmpolld-client.h
@@ -16,7 +16,7 @@
 #define _LVM_LVMPOLLD_CLIENT_H
 #  ifdef LVMPOLLD_SUPPORT
 
-#	include "daemon-client.h"
+#	include "libdaemon/client/daemon-client.h"
 
 #	define LVMPOLLD_SOCKET DEFAULT_RUN_DIR "/lvmpolld.socket"
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 5b01873..9c775c4 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -426,7 +426,7 @@ static int _activate_lv_like_model(struct logical_volume *model,
 {
 	/* FIXME: run all cases through lv_active_change when clvm variants are gone. */
 
-	if (vg_is_shared(vg))
+	if (vg_is_shared(lv->vg))
 		return lv_active_change(lv->vg->cmd, lv, CHANGE_AEY, 0);
 
 	if (lv_is_active_exclusive(model)) {
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 68194b8..1daf364 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -642,7 +642,7 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 	 * other hosts.  For LVs that are active on multiple hosts (sh), we
 	 * would need to used cluster mirrors.
 	 */
-	if (vg_is_shared(vg))) {
+	if (vg_is_shared(vg)) {
 		if (!lv) {
 			log_error("pvmove in a shared VG requires a named LV.");
 			return ECMD_FAILED;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index c7c2744..7cba0f4 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -197,7 +197,7 @@ static int _pvscan_autoactivate_single(struct cmd_context *cmd, const char *vg_n
 	if (vg_is_exported(vg))
 		return ECMD_PROCESSED;
 
-	if (vg_is_shared(vg)))
+	if (vg_is_shared(vg))
 		return ECMD_PROCESSED;
 
 	log_debug("pvscan autoactivating VG %s.", vg_name);


