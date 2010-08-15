From: Jonathan Brassow <jbrassow@redhat.com>
Date: Sun, 15 Aug 2010 17:28:45 -0500
Subject: [PATCH 1 of 3] Handle failures of mirror devices while under snapshot origin (bug 613829)
Message-ID: <1281911325.30206.3.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch makes it possible to monitor mirrors which may
be under a snapshot origin.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/activate/activate.c
===================================================================
--- LVM2.orig/lib/activate/activate.c
+++ LVM2/lib/activate/activate.c
@@ -772,7 +772,8 @@ int monitor_dev_for_events(struct cmd_co
 			if (!monitor_dev_for_events(cmd, dm_list_struct_base(snh,
 				    struct lv_segment, origin_list)->cow, monitor))
 				r = 0;
-		return r;
+		if (!lv_is_mirrored(lv))
+			return r;
 	}
 
 	/*
Index: LVM2/lib/mirror/mirrored.c
===================================================================
--- LVM2.orig/lib/mirror/mirrored.c
+++ LVM2/lib/mirror/mirrored.c
@@ -631,18 +631,16 @@ static int _target_set_events(struct lv_
 			      int evmask __attribute__((unused)), int set)
 {
 	char *dso, *uuid;
-	struct logical_volume *lv;
-	struct volume_group *vg;
+	struct logical_volume *lv = seg->lv;
+	struct volume_group *vg = lv->vg;
+	char *suffix = lv_is_origin(lv) ? "real" : NULL;
 	struct dm_event_handler *dmevh;
 	int r;
 
-	lv = seg->lv;
-	vg = lv->vg;
-
 	if (!_get_mirror_dso_path(vg->cmd, &dso))
 		return_0;
 
-	if (!(uuid = build_dm_uuid(vg->cmd->mem, lv->lvid.s, NULL)))
+	if (!(uuid = build_dm_uuid(vg->cmd->mem, lv->lvid.s, suffix)))
 		return_0;
 
 	if (!(dmevh = _create_dm_event_handler(uuid, dso, DM_EVENT_ALL_ERRORS)))



