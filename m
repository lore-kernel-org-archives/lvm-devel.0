From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Feb 2013 18:08:01 +0000 (UTC)
Subject: master - use lv_layer
Message-ID: <20130204180801.223333523@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4af4241ba4f749ee64375e7e80fecf6bda67f1e8
Commit:        4af4241ba4f749ee64375e7e80fecf6bda67f1e8
Parent:        ca7abbce8a705c1e690bcc2b0c08c4b510843046
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 2 00:16:36 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 4 19:01:10 2013 +0100

use lv_layer

---
 lib/activate/dev_manager.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index fda5bdc..de42b3b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -827,7 +827,7 @@ int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
 	char *type = NULL;
 	char *params = NULL;
 	char *dlid = NULL;
-	const char *layer = lv_is_origin(lv) ? "real" : NULL;
+	const char *layer = lv_layer(lv);
 	const struct dm_list *segh = &lv->segments;
 	struct lv_segment *seg = NULL;
 
@@ -998,7 +998,7 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 	char *name;
 	const char *dlid;
 	const char *target_type = first_seg(lv)->segtype->name;
-	const char *layer = (lv_is_origin(lv)) ? "real" : NULL;
+	const char *layer = lv_layer(lv);
 
 	/*
 	 * Build a name for the top layer.
@@ -1193,7 +1193,7 @@ int dev_manager_thin_percent(struct dev_manager *dm,
 {
 	char *name;
 	const char *dlid;
-	const char *layer = lv_is_origin(lv) ? "real" : NULL;
+	const char *layer = lv_layer(lv);
 
 	/* Build a name for the top layer */
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))


