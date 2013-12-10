From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Dec 2013 10:18:53 +0000 (UTC)
Subject: master - cleanup: shorter raid initialization
Message-ID: <20131210101853.3BF70601DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf857ecabdb3ef54e42a326d08c33b0518a5b3e4
Commit:        cf857ecabdb3ef54e42a326d08c33b0518a5b3e4
Parent:        9f0e27a18c60193feae83e458f821efc6ac64683
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 6 16:38:11 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 11:16:51 2013 +0100

cleanup: shorter raid initialization

Avoid multiple queries for raid library for each initialized raid
seg type and use shorter code.
---
 WHATS_NEW       |    1 +
 lib/raid/raid.c |  152 ++++++++++++++-----------------------------------------
 2 files changed, 39 insertions(+), 114 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2596509..44b545a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Shortened code for initialization of raid segment types.
   Cache global library dir in command context.
   Return success when inserting dirs and links into device cache.
   Test for remote exclusive activation after activation fails.
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index c963fd2..956472e 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -393,115 +393,47 @@ static struct segtype_handler _raid_ops = {
 	.destroy = _raid_destroy,
 };
 
+static const struct raid_type {
+	const char name[12];
+	unsigned parity;
+	int extra_flags;
+} _raid_types[] = {
+	{ "raid1",    0, SEG_AREAS_MIRRORED },
+	{ "raid10",   0, SEG_AREAS_MIRRORED },
+	{ "raid4",    1 },
+	{ "raid5",    1 },
+	{ "raid5_la", 1 },
+	{ "raid5_ls", 1 },
+	{ "raid5_ra", 1 },
+	{ "raid5_rs", 1 },
+	{ "raid6",    2 },
+	{ "raid6_nc", 2 },
+	{ "raid6_nr", 2 },
+	{ "raid6_zr", 2 }
+};
+
 static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
-					       const char *raid_type)
+					       const struct raid_type *rt,
+					       int monitored)
 {
 	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
 	if (!segtype) {
 		log_error("Failed to allocate memory for %s segtype",
-			  raid_type);
+			  rt->name);
 		return NULL;
 	}
 	segtype->cmd = cmd;
-
-	segtype->flags = SEG_RAID;
-#ifdef DEVMAPPER_SUPPORT
-#ifdef DMEVENTD
-	if (_get_raid_dso_path(cmd))
-		segtype->flags |= SEG_MONITORED;
-#endif
-#endif
-	segtype->parity_devs = strstr(raid_type, "raid6") ? 2 : 1;
-
 	segtype->ops = &_raid_ops;
-	segtype->name = raid_type;
-
-	segtype->private = NULL;
+	segtype->name = rt->name;
+	segtype->flags = SEG_RAID | rt->extra_flags | monitored;
+	segtype->parity_devs = rt->parity;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
 	return segtype;
 }
 
-static struct segment_type *_init_raid1_segtype(struct cmd_context *cmd)
-{
-	struct segment_type *segtype;
-
-	segtype = _init_raid_segtype(cmd, "raid1");
-	if (!segtype)
-		return NULL;
-
-	segtype->flags |= SEG_AREAS_MIRRORED;
-	segtype->parity_devs = 0;
-
-	return segtype;
-}
-
-static struct segment_type *_init_raid10_segtype(struct cmd_context *cmd)
-{
-	struct segment_type *segtype;
-
-	segtype = _init_raid_segtype(cmd, "raid10");
-	if (!segtype)
-		return NULL;
-
-	segtype->flags |= SEG_AREAS_MIRRORED;
-	segtype->parity_devs = 0;
-
-	return segtype;
-}
-
-static struct segment_type *_init_raid4_segtype(struct cmd_context *cmd)
-{
-	return _init_raid_segtype(cmd, "raid4");
-}
-
-static struct segment_type *_init_raid5_segtype(struct cmd_context *cmd)
-{
-	return _init_raid_segtype(cmd, "raid5");
-}
-
-static struct segment_type *_init_raid5_la_segtype(struct cmd_context *cmd)
-{
-	return _init_raid_segtype(cmd, "raid5_la");
-}
-
-static struct segment_type *_init_raid5_ra_segtype(struct cmd_context *cmd)
-{
-	return _init_raid_segtype(cmd, "raid5_ra");
-}
-
-static struct segment_type *_init_raid5_ls_segtype(struct cmd_context *cmd)
-{
-	return _init_raid_segtype(cmd, "raid5_ls");
-}
-
-static struct segment_type *_init_raid5_rs_segtype(struct cmd_context *cmd)
-{
-	return _init_raid_segtype(cmd, "raid5_rs");
-}
-
-static struct segment_type *_init_raid6_segtype(struct cmd_context *cmd)
-{
-	return _init_raid_segtype(cmd, "raid6");
-}
-
-static struct segment_type *_init_raid6_zr_segtype(struct cmd_context *cmd)
-{
-	return _init_raid_segtype(cmd, "raid6_zr");
-}
-
-static struct segment_type *_init_raid6_nr_segtype(struct cmd_context *cmd)
-{
-	return _init_raid_segtype(cmd, "raid6_nr");
-}
-
-static struct segment_type *_init_raid6_nc_segtype(struct cmd_context *cmd)
-{
-	return _init_raid_segtype(cmd, "raid6_nc");
-}
-
 #ifdef RAID_INTERNAL /* Shared */
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib)
 #else
@@ -511,29 +443,21 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 #endif
 {
 	struct segment_type *segtype;
-	unsigned i = 0;
-	struct segment_type *(*raid_segtype_fn[])(struct cmd_context *) =  {
-		_init_raid1_segtype,
-		_init_raid10_segtype,
-		_init_raid4_segtype,
-		_init_raid5_segtype,
-		_init_raid5_la_segtype,
-		_init_raid5_ra_segtype,
-		_init_raid5_ls_segtype,
-		_init_raid5_rs_segtype,
-		_init_raid6_segtype,
-		_init_raid6_zr_segtype,
-		_init_raid6_nr_segtype,
-		_init_raid6_nc_segtype,
-		NULL,
-	};
-
-	do {
-		if ((segtype = raid_segtype_fn[i](cmd)) &&
+	unsigned i;
+	int monitored = 0;
+
+#ifdef DEVMAPPER_SUPPORT
+#ifdef DMEVENTD
+	if (_get_raid_dso_path(cmd))
+		monitored = SEG_MONITORED;
+#endif
+#endif
+
+	for (i = 0; i < DM_ARRAY_SIZE(_raid_types); ++i)
+		if ((segtype = _init_raid_segtype(cmd, &_raid_types[i], monitored)) &&
 		    !lvm_register_segtype(seglib, segtype))
 			/* segtype is already destroyed */
 			return_0;
-	} while (raid_segtype_fn[++i]);
 
 	return 1;
 }


