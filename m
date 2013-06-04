From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:56 +0000 (UTC)
Subject: dev-mornfall-activate - libdm: add dm_get_status_snapshot
Message-ID: <20130604192656.409F760FCA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4707ac7200ba559ad080e4349f660c0a7559610c
Commit:        4707ac7200ba559ad080e4349f660c0a7559610c
Parent:        3ba3bc0d6641db5b02e63759949388a840f58d48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 26 16:57:50 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 27 10:30:51 2013 +0200

libdm: add dm_get_status_snapshot

Add dm_get_status_snapshot() for parsing snapshot status.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdevmapper.h  |   20 +++++++++++++++++++-
 libdm/libdm-deptree.c |   39 ++++++++++++++++++++++++++++++++++++++-
 3 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9132e01..99e8269 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Add dm_get_status_snapshot() for parsing snapshot status.
   Detecte mounted fs also via reading /proc/self/mountinfo.
   Add dm_mountinfo_read() for parsing /proc/self/mountinfo.
   Report error for nonexisting devices in dmeventd communication.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index d9cd280..1bf5807 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -286,6 +286,24 @@ struct dm_status_raid {
 int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		       struct dm_status_raid **status);
 
+
+/*
+ * Snapshot target's format:
+ * <= 1.7.0: <used_sectors>/<total_sectors>
+ * >= 1.8.0: <used_sectors>/<total_sectors> <metadata_sectors>
+ */
+struct dm_status_snapshot {
+	uint64_t used_sectors;          /* in 512b units */
+	uint64_t total_sectors;
+	uint64_t metadata_sectors;
+	unsigned has_metadata_sectors : 1; /* set when metadata_sectors is present */
+	unsigned invalid : 1;		/* set when snapshot is invalidated */
+	unsigned merge_failed : 1;	/* set when snapshot merge failed */
+};
+
+int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
+			   struct dm_status_snapshot **status);
+
 /*
  * Parse params from STATUS call for thin_pool target
  */
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 115754b..56522f1 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -2718,6 +2718,43 @@ int dm_tree_node_add_snapshot_merge_target(struct dm_tree_node *node,
 				    merge_uuid, 1, chunk_size);
 }
 
+int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
+			   struct dm_status_snapshot **status)
+{
+	struct dm_status_snapshot *s;
+	int r;
+
+	if (!params) {
+		log_error("Failed to parse invalid snapshot params.");
+		return 0;
+	}
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(*s)))) {
+		log_error("Failed to allocate snapshot status structure.");
+		return 0;
+	}
+
+	r = sscanf(params, "%" PRIu64 "/%" PRIu64 " %" PRIu64,
+		   &s->used_sectors, &s->total_sectors,
+		   &s->metadata_sectors);
+
+	if (r == 3 || r == 2)
+		s->has_metadata_sectors = (r == 3);
+	else if (!strcmp(params, "Invalid"))
+		s->invalid = 1;
+	else if (!strcmp(params, "Merge failed"))
+		s->merge_failed = 1;
+	else {
+		dm_pool_free(mem, s);
+		log_error("Failed to parse snapshot params: %s.", params);
+		return 0;
+	}
+
+	*status = s;
+
+	return 1;
+}
+
 int dm_tree_node_add_error_target(struct dm_tree_node *node,
 				     uint64_t size)
 {


