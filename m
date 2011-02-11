From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:30:52 +0100
Subject: [PATCH 06/16] Fix !DEVMAPPER_SUPPORT build
In-Reply-To: <cover.1297419991.git.zkabelac@redhat.com>
References: <cover.1297419991.git.zkabelac@redhat.com>
Message-ID: <0e9e6db6d0df3621368ebafd9c4f9992862467d7.1297419991.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |   35 ++++++++++++++++++++++++++++++-----
 lib/mirror/mirrored.c   |    2 ++
 lib/snapshot/snapshot.c |    2 ++
 3 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index e75415b..f39a066 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -171,7 +171,7 @@ int lvs_in_vg_activated(struct volume_group *vg)
 {
 	return 0;
 }
-int lvs_in_vg_opened(struct volume_group *vg)
+int lvs_in_vg_opened(const struct volume_group *vg)
 {
 	return 0;
 }
@@ -181,15 +181,15 @@ int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
 	return 1;
 }
 *******/
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s)
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
 	return 1;
 }
-int lv_resume(struct cmd_context *cmd, const char *lvid_s)
+int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
 	return 1;
 }
-int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s)
+int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
 	return 1;
 }
@@ -232,6 +232,31 @@ void activation_exit(void)
 	return;
 }
 
+int lv_is_active(struct logical_volume *lv)
+{
+	return 0;
+}
+
+int lv_is_active_exclusive_locally(struct logical_volume *lv)
+{
+	return 0;
+}
+
+int lv_is_active_exclusive_remotely(struct logical_volume *lv)
+{
+	return 0;
+}
+
+int lv_check_transient(struct logical_volume *lv)
+{
+	return 0;
+}
+
+int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
+			   unsigned origin_only, int monitor)
+{
+	return 1;
+}
 #else				/* DEVMAPPER_SUPPORT */
 
 static int _activation = 1;
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 0bf3b3b..7de2f70 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -641,10 +641,12 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 	segtype->private = NULL;
 	segtype->flags = SEG_AREAS_MIRRORED;
 
+#ifdef DEVMAPPER_SUPPORT
 #ifdef DMEVENTD
 	if (_get_mirror_dso_path(cmd))
 		segtype->flags |= SEG_MONITORED;
 #endif
+#endif
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 1a98d7e..af5d708 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -260,10 +260,12 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 	segtype->private = NULL;
 	segtype->flags = SEG_SNAPSHOT;
 
+#ifdef DEVMAPPER_SUPPORT
 #ifdef DMEVENTD
 	if (_get_snapshot_dso_path(cmd))
 		segtype->flags |= SEG_MONITORED;
 #endif
+#endif
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
 	return segtype;
-- 
1.7.4


