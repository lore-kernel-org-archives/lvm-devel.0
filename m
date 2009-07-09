From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 03:08:40 -0400
Subject: [PATCH 2/9] Add defines for default vgcreate parameters.
In-Reply-To: <1247123327-26141-2-git-send-email-dwysocha@redhat.com>
References: <1247123327-26141-1-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1247123327-26141-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/config/defaults.h |    8 ++++++--
 tools/vgcreate.c      |    8 ++++----
 tools/vgsplit.c       |    2 +-
 3 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 98c023a..ee6d758 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -1,6 +1,6 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -66,6 +66,10 @@
 #define DEFAULT_LABELSECTOR UINT64_C(1)
 #define DEFAULT_READ_AHEAD "auto"
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */
+#define DEFAULT_MAX_PV 0
+#define DEFAULT_MAX_LV 0
+#define DEFAULT_ALLOC_POLICY ALLOC_NORMAL
+#define DEFAULT_CLUSTERED 0
 
 #define DEFAULT_MSG_PREFIX "  "
 #define DEFAULT_CMD_NAME 0
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 232b570..353611b 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -36,10 +36,10 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	vp_def.vg_name = NULL;
 	vp_def.extent_size = DEFAULT_EXTENT_SIZE * 2;
-	vp_def.max_pv = 0;
-	vp_def.max_lv = 0;
-	vp_def.alloc = ALLOC_NORMAL;
-	vp_def.clustered = 0;
+	vp_def.max_pv = DEFAULT_MAX_PV;
+	vp_def.max_lv = DEFAULT_MAX_LV;
+	vp_def.alloc = DEFAULT_ALLOC_POLICY;
+	vp_def.clustered = DEFAULT_CLUSTERED;
 	if (fill_vg_create_params(cmd, argv[0], &vp_new, &vp_def))
 		return EINVALID_CMD_LINE;
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index e14e01c..573dfb6 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -368,7 +368,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		vp_def.max_pv = vg_from->max_pv;
 		vp_def.max_lv = vg_from->max_lv;
 		vp_def.alloc = vg_from->alloc;
-		vp_def.clustered = 0;
+		vp_def.clustered = DEFAULT_CLUSTERED;
 
 		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def)) {
 			r = EINVALID_CMD_LINE;
-- 
1.6.0.6


