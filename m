From: David Teigland <teigland@sourceware.org>
Date: Wed, 14 Sep 2022 19:23:15 +0000 (GMT)
Subject: main - vgremove: remove online files in run dir
Message-ID: <20220914192315.3204838582BF@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0887896847807e159a70edc5ac92a4030c13923a
Commit:        0887896847807e159a70edc5ac92a4030c13923a
Parent:        a2d33cdfc516d946d390645cc694e745008b6fc0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 14 09:13:58 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 14 14:19:29 2022 -0500

vgremove: remove online files in run dir

These files are automatically cleared on reboot given
that /run is tmpfs, and that remains the primary way
of clearing online files.

But, if there's extreme use of vgcreate+pvscan+vgremove
between reboots, then removing online files in vgremove
will limit the number of unused online files using space
in /run.
---
 lib/device/online.c               | 56 +++++++++++++++++++++++++++++++++++++++
 lib/device/online.h               |  2 ++
 test/shell/vgchange-pvs-online.sh | 39 +++++++++++++++++++++++++--
 tools/pvscan.c                    | 17 +-----------
 tools/vgremove.c                  |  3 +++
 5 files changed, 99 insertions(+), 18 deletions(-)

diff --git a/lib/device/online.c b/lib/device/online.c
index 79652d990..7ffe14b18 100644
--- a/lib/device/online.c
+++ b/lib/device/online.c
@@ -17,6 +17,7 @@
 #include "lib/commands/toolcontext.h"
 #include "lib/device/device.h"
 #include "lib/device/online.h"
+#include "lib/metadata/metadata.h"
 
 #include <dirent.h>
 
@@ -504,3 +505,58 @@ do_lookup:
 	if ((rv < 0) && stat(PVS_LOOKUP_DIR, &st))
 		log_error_pvscan(cmd, "Failed to create %s %d", PVS_LOOKUP_DIR, errno);
 }
+
+void online_lookup_file_remove(const char *vgname)
+{
+	char path[PATH_MAX];
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", PVS_LOOKUP_DIR, vgname) < 0) {
+		log_error("Path %s/%s is too long.", PVS_LOOKUP_DIR, vgname);
+		return;
+	}
+
+	log_debug("Unlink pvs_lookup: %s", path);
+
+	if (unlink(path) && (errno != ENOENT))
+		log_sys_debug("unlink", path);
+}
+
+static int _online_pvid_file_remove(char *pvid)
+{
+	char path[PATH_MAX];
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, pvid) < 0)
+		return_0;
+	if (!unlink(path))
+		return 1;
+	return 0;
+}
+
+/*
+ * Reboot automatically clearing tmpfs on /run is the main method of removing
+ * online files.  It's important to note that removing the online files for a
+ * VG is not a technical requirement for anything and could easily be skipped
+ * if it had any downside.  It's only done to clean up the space used in /run
+ * by the online files, e.g. if there happens to be an extreme amount of
+ * vgcreate/pvscan/vgremove between reboots that are leaving a large number of
+ * useless online files consuming tmpfs space.
+ */
+void online_vgremove(struct volume_group *vg)
+{
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	struct pv_list *pvl;
+
+	/*
+	 * online files may not exist for the vg if there has been no
+	 * pvscans or autoactivation.
+	 */
+
+	online_vg_file_remove(vg->name);
+	online_lookup_file_remove(vg->name);
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
+		_online_pvid_file_remove(pvid);
+	}
+}
+
diff --git a/lib/device/online.h b/lib/device/online.h
index 850b03db8..488129e3f 100644
--- a/lib/device/online.h
+++ b/lib/device/online.h
@@ -54,5 +54,7 @@ void online_dir_setup(struct cmd_context *cmd);
 int get_pvs_online(struct dm_list *pvs_online, const char *vgname);
 int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname);
 void free_po_list(struct dm_list *list);
+void online_lookup_file_remove(const char *vgname);
+void online_vgremove(struct volume_group *vg);
 
 #endif
diff --git a/test/shell/vgchange-pvs-online.sh b/test/shell/vgchange-pvs-online.sh
index 8812de1a3..a1fc3a427 100644
--- a/test/shell/vgchange-pvs-online.sh
+++ b/test/shell/vgchange-pvs-online.sh
@@ -192,6 +192,41 @@ check lv_field $vg2/$lv1 lv_active "active"
 vgchange -an $vg1
 vgchange -an $vg2
 
-vgremove -f $vg1
-vgremove -f $vg2
+# vgremove clears online files
+
+PVID1=$(pvs "$bd1" --noheading -o uuid | tr -d - | awk '{print $1}')
+PVID2=$(pvs "$bd2" --noheading -o uuid | tr -d - | awk '{print $1}')
+PVID3=$(pvs "$bd3" --noheading -o uuid | tr -d - | awk '{print $1}')
+
+_clear_online_files
+
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$bd1"
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$bd2"
+vgchange -aay --autoactivation event $vg1
+check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg1/$lv2 lv_active "active"
+check lv_field $vg2/$lv1 lv_active ""
+
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$bd3"
+vgchange -aay --autoactivation event $vg2
+check lv_field $vg2/$lv1 lv_active "active"
+
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+ls "$RUNDIR/lvm/pvs_online/$PVID3"
+ls "$RUNDIR/lvm/pvs_lookup/$vg1"
+ls "$RUNDIR/lvm/vgs_online/$vg1"
+ls "$RUNDIR/lvm/vgs_online/$vg2"
+
+vgremove -y $vg1
+
+not ls "$RUNDIR/lvm/pvs_online/$PVID1"
+not ls "$RUNDIR/lvm/pvs_online/$PVID2"
+not ls "$RUNDIR/lvm/pvs_lookup/$vg1"
+not ls "$RUNDIR/lvm/vgs_online/$vg1"
+
+vgremove -y $vg2
+
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+not ls "$RUNDIR/lvm/vgs_online/$vg2"
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 72c3279c3..1c58e4a5b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -177,21 +177,6 @@ out:
 	return ret;
 }
 
-static void _lookup_file_remove(char *vgname)
-{
-	char path[PATH_MAX];
-
-	if (dm_snprintf(path, sizeof(path), "%s/%s", PVS_LOOKUP_DIR, vgname) < 0) {
-		log_error("Path %s/%s is too long.", PVS_LOOKUP_DIR, vgname);
-		return;
-	}
-
-	log_debug("Unlink pvs_lookup: %s", path);
-
-	if (unlink(path) && (errno != ENOENT))
-		log_sys_debug("unlink", path);
-}
-
 /*
  * When a device goes offline we only know its major:minor, not its PVID.
  * Since the dev isn't around, we can't read it to get its PVID, so we have to
@@ -233,7 +218,7 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 
 			if (file_vgname[0]) {
 				online_vg_file_remove(file_vgname);
-				_lookup_file_remove(file_vgname);
+				online_lookup_file_remove(file_vgname);
 			}
 		}
 	}
diff --git a/tools/vgremove.c b/tools/vgremove.c
index b6685ae2a..a3252ae80 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+#include "lib/device/online.h"
 
 static int _vgremove_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
@@ -75,6 +76,8 @@ static int _vgremove_single(struct cmd_context *cmd, const char *vg_name,
 	if (!force && !vg_remove_check(vg))
 		return_ECMD_FAILED;
 
+	online_vgremove(vg);
+
 	vg_remove_pvs(vg);
 
 	if (!vg_remove(vg))

