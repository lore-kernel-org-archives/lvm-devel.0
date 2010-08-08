From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:36 +0200
Subject: [PATCH 24/25] Replicator: lvremove implementation
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <5ada6e0660459234ab9056d30b320d3fb552a1a1.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/commands.h |    3 ++-
 tools/lvremove.c |   18 +++++++++++++++++-
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index a2b6690..1387eda 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -365,12 +365,13 @@ xx(lvremove,
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[--noudevsync]\n"
+   "\t[--site SiteName]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
-   autobackup_ARG, force_ARG, noudevsync_ARG, test_ARG)
+   autobackup_ARG, force_ARG, noudevsync_ARG, site_ARG, test_ARG)
 
 xx(lvrename,
    "Rename a logical volume",
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 0252149..8060146 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -19,6 +19,8 @@ static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute__((unused)))
 {
 	struct logical_volume *origin;
+	struct logical_volume *replicator;
+	const char *site_name;
 
 	/*
 	 * If this is a sparse device, remove its origin too.
@@ -26,6 +28,20 @@ static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
         if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
                 lv = origin;
 
+	if ((lv_is_replicated(lv) || lv_is_replicator(lv)) &&
+	    arg_count(cmd, site_ARG)) {
+		replicator = lv_is_replicator(lv) ? lv : first_seg(lv)->replicator;
+		site_name = arg_str_value(cmd, site_ARG,
+					  DEFAULT_REPLICATOR_LOCAL_SITE_NAME);
+
+		if (!lv_remove_replicator_site(replicator, site_name)) {
+			stack;
+			return ECMD_FAILED;
+		}
+
+		return ECMD_PROCESSED;
+	}
+
 	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG), 0)) {
 		stack;
 		return ECMD_FAILED;
-- 
1.7.2.1


