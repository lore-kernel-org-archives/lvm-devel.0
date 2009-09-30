From: Takahiro Yasui <tyasui@redhat.com>
Date: Tue, 29 Sep 2009 20:28:22 -0400
Subject: [RFC][PATCH 5/5] update device lists by lvm commands
Message-ID: <4AC2A626.50404@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

dmeventd keeps information of PVs which belongs to the VG and the
information needs to be updated when the structure of VG is changed
by LVM commands: vgextend, vgmerge, vgreduce and vgsplit.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 tools/toollib.c  |   29 +++++++++++++++++++++++++++++
 tools/toollib.h  |    2 ++
 tools/vgextend.c |    3 +++
 tools/vgmerge.c  |    3 +++
 tools/vgreduce.c |    4 ++++
 tools/vgsplit.c  |    7 +++++++
 6 files changed, 48 insertions(+)

Index: LVM2.02.54-20090928/tools/toollib.c
===================================================================
--- LVM2.02.54-20090928.orig/tools/toollib.c
+++ LVM2.02.54-20090928/tools/toollib.c
@@ -1247,3 +1247,32 @@ int vg_refresh_visible(struct cmd_contex
 	
 	return r;
 }
+
+void vg_monitor_update(struct cmd_context *cmd, struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	struct logical_volume *lv;
+	struct lvinfo info;
+	int lv_active;
+
+	if (dmeventd_monitor_mode() == DMEVENTD_MONITOR_IGNORE)
+		return;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		lv = lvl->lv;
+
+		if (!lv_info(cmd, lv, &info, 0, 0))
+			lv_active = 0;
+		else
+			lv_active = info.exists;
+
+		/*
+		 * FIXME: Need to consider all cases... PVMOVE, etc
+		 */
+		if ((lv->status & PVMOVE) || !lv_active)
+			continue;
+
+		if (monitor_dev_for_events(cmd, lv, 0))
+			monitor_dev_for_events(cmd, lv, 1);
+	}
+}
Index: LVM2.02.54-20090928/tools/toollib.h
===================================================================
--- LVM2.02.54-20090928.orig/tools/toollib.h
+++ LVM2.02.54-20090928/tools/toollib.h
@@ -105,4 +105,6 @@ int fill_vg_create_params(struct cmd_con
 
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv);
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
+
+void vg_monitor_update(struct cmd_context *cmd, struct volume_group *vg);
 #endif
Index: LVM2.02.54-20090928/tools/vgextend.c
===================================================================
--- LVM2.02.54-20090928.orig/tools/vgextend.c
+++ LVM2.02.54-20090928/tools/vgextend.c
@@ -69,6 +69,9 @@ int vgextend(struct cmd_context *cmd, in
 	log_print("Volume group \"%s\" successfully extended", vg_name);
 	r = ECMD_PROCESSED;
 
+	/* update monitoring information */
+	vg_monitor_update(cmd, vg);
+
 bad:
 	unlock_vg(cmd, VG_ORPHANS);
 	unlock_and_release_vg(cmd, vg, vg_name);
Index: LVM2.02.54-20090928/tools/vgmerge.c
===================================================================
--- LVM2.02.54-20090928.orig/tools/vgmerge.c
+++ LVM2.02.54-20090928/tools/vgmerge.c
@@ -144,6 +144,9 @@ static int _vgmerge_single(struct cmd_co
 	log_print("Volume group \"%s\" successfully merged into \"%s\"",
 		  vg_from->name, vg_to->name);
 	r = ECMD_PROCESSED;
+
+	/* update monitoring information */
+	vg_monitor_update(cmd, vg_to);
 bad:
 	if (lock_vg_from_first) {
 		unlock_and_release_vg(cmd, vg_to, vg_name_to);
Index: LVM2.02.54-20090928/tools/vgreduce.c
===================================================================
--- LVM2.02.54-20090928.orig/tools/vgreduce.c
+++ LVM2.02.54-20090928/tools/vgreduce.c
@@ -571,6 +571,10 @@ int vgreduce(struct cmd_context *cmd, in
 				      _vgreduce_single);
 
 	}
+
+	/* update monitoring information */
+	vg_monitor_update(cmd, vg);
+
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 	unlock_and_release_vg(cmd, vg, vg_name);
Index: LVM2.02.54-20090928/tools/vgsplit.c
===================================================================
--- LVM2.02.54-20090928.orig/tools/vgsplit.c
+++ LVM2.02.54-20090928/tools/vgsplit.c
@@ -488,6 +488,13 @@ int vgsplit(struct cmd_context *cmd, int
 
 	r = ECMD_PROCESSED;
 
+	/*
+	 * update monitoring information of "vg_to"
+	 *
+	 * Note: update is not necessary to "vg_from" because it contains
+	 * no active LVs.
+	 */
+	vg_monitor_update(cmd, vg_to);
 bad:
 	if (lock_vg_from_first) {
 		unlock_and_release_vg(cmd, vg_to, vg_name_to);

-- 
Takahiro Yasui
Hitachi Computer Products (America), Inc.


