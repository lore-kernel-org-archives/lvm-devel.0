From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 12 Dec 2012 12:07:03 +0000 (UTC)
Subject: master - lvmetad: Fix autoactivation for MDA-less PVs.
Message-ID: <20121212120703.5DAACA0C3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=789a45d6d7567c467250db661b937422e03f491d
Commit:        789a45d6d7567c467250db661b937422e03f491d
Parent:        cad22be3942809bac979d42195ea5a861a91a71f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Dec 12 12:51:28 2012 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Dec 12 13:06:26 2012 +0100

lvmetad: Fix autoactivation for MDA-less PVs.

---
 lib/cache/lvmetad.c                |   12 +++------
 lib/cache/lvmetad.h                |    3 +-
 test/shell/lvmetad-pvscan-nomda.sh |   49 ++++++++++++++++++++++++++++++++++++
 tools/pvscan.c                     |   22 ++++++++++++++-
 4 files changed, 75 insertions(+), 11 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index e5c5f51..a636f43 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -675,7 +675,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *device, const struct
 	daemon_reply reply;
 	struct lvmcache_info *info;
 	struct dm_config_tree *pvmeta, *vgmeta;
-	const char *status;
+	const char *status, *vgid;
 	int result;
 
 	if (!lvmetad_active() || test_mode())
@@ -724,11 +724,6 @@ int lvmetad_pv_found(const struct id *pvid, struct device *device, const struct
 				      NULL);
 		dm_config_destroy(vgmeta);
 	} else {
-		if (handler) {
-			log_error(INTERNAL_ERROR "Handler needs existing VG.");
-			dm_config_destroy(pvmeta);
-			return 0;
-		}
 		/* There are no MDAs on this PV. */
 		reply = _lvmetad_send("pv_found", "pvmeta = %t", pvmeta, NULL);
 	}
@@ -744,10 +739,11 @@ int lvmetad_pv_found(const struct id *pvid, struct device *device, const struct
 
 	if (result && handler) {
 		status = daemon_reply_str(reply, "status", "<missing>");
+		vgid = daemon_reply_str(reply, "vgid", "<missing>");
 		if (!strcmp(status, "partial"))
-			handler(vg, 1, CHANGE_AAY);
+			handler(_lvmetad_cmd, vgid, 1, CHANGE_AAY);
 		else if (!strcmp(status, "complete"))
-			handler(vg, 0, CHANGE_AAY);
+			handler(_lvmetad_cmd, vgid, 0, CHANGE_AAY);
 		else if (!strcmp(status, "orphan"))
 			;
 		else
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 5f0f552..c644069 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -22,7 +22,8 @@ struct cmd_context;
 struct dm_config_tree;
 enum activation_change;
 
-typedef int (*activation_handler) (struct volume_group *vg, int partial,
+typedef int (*activation_handler) (struct cmd_context *cmd,
+				   const char *vgid, int partial,
 				   enum activation_change activate);
 
 #ifdef LVMETAD_SUPPORT
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
new file mode 100644
index 0000000..c04a275
--- /dev/null
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -0,0 +1,49 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+test -e LOCAL_LVMETAD || skip
+kill $(cat LOCAL_LVMETAD)
+rm LOCAL_LVMETAD
+
+aux prepare_devs 2
+
+pvcreate --metadatacopies 0 $dev1
+pvcreate --metadatacopies 1 $dev2
+vgcreate $vg1 $dev1 $dev2
+lvcreate -n foo -l 1 -an --zero n $vg1
+
+# start lvmetad but make sure it doesn't know about $dev1 or $dev2
+aux disable_dev $dev1
+aux disable_dev $dev2
+aux prepare_lvmetad
+lvs
+mv LOCAL_LVMETAD XXX
+aux enable_dev $dev2
+aux enable_dev $dev1
+mv XXX LOCAL_LVMETAD
+
+aux lvmconf 'global/use_lvmetad = 0'
+check inactive $vg1 foo
+aux lvmconf 'global/use_lvmetad = 1'
+
+pvscan --cache $dev2 -aay
+
+aux lvmconf 'global/use_lvmetad = 0'
+check inactive $vg1 foo
+aux lvmconf 'global/use_lvmetad = 1'
+
+pvscan --cache $dev1 -aay
+
+aux lvmconf 'global/use_lvmetad = 0'
+check active $vg1 foo
+aux lvmconf 'global/use_lvmetad = 1'
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 34ab792..81849f5 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -91,18 +91,36 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 				display_size(cmd, (uint64_t) (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * pv_pe_size(pv)));
 }
 
-static int _auto_activation_handler(struct volume_group *vg, int partial,
+static int _auto_activation_handler(struct cmd_context *cmd,
+				    const char *vgid, int partial,
 				    activation_change_t activate)
 {
+	struct volume_group *vg;
+	int consistent = 0;
+	struct id vgid_raw;
+
 	/* TODO: add support for partial and clustered VGs */
-	if (partial || vg_is_clustered(vg))
+	if (partial)
 		return 1;
 
+	id_read_format(&vgid_raw, vgid);
+	/* NB. This is safe because we know lvmetad is running and we won't hit
+	 * disk. */
+	if (!(vg = vg_read_internal(cmd, NULL, &vgid_raw, 0, &consistent)))
+	    return 1;
+
+	if (vg_is_clustered(vg)) {
+		release_vg(vg);
+		return 1;
+	}
+
 	if (!vgchange_activate(vg->cmd, vg, activate)) {
 		log_error("%s: autoactivation failed.", vg->name);
+		release_vg(vg);
 		return 0;
 	}
 
+	release_vg(vg);
 	return 1;
 }
 


