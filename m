From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:54 +0000 (UTC)
Subject: master - cleanup: drop unneeded assigns
Message-ID: <20160211173954.7F08860365@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a32d2c1d95e5cdd1849fc979353a81edf972878
Commit:        5a32d2c1d95e5cdd1849fc979353a81edf972878
Parent:        032cf8ade6904df38b25453d94169ae17fac003a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 8 13:14:43 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:35:07 2016 +0100

cleanup: drop unneeded assigns

---
 tools/lvresize.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index d1c20b6..af6ce07 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -168,7 +168,7 @@ static int _lvresize_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg, struct processing_handle *handle)
 {
 	struct lvresize_params *lp = (struct lvresize_params *) handle->custom_handle;
-	struct dm_list *pvh = NULL;
+	struct dm_list *pvh;
 	struct logical_volume *lv;
 	int ret = ECMD_FAILED;
 
@@ -197,7 +197,7 @@ out:
 
 int lvresize(struct cmd_context *cmd, int argc, char **argv)
 {
-	struct processing_handle *handle = NULL;
+	struct processing_handle *handle;
 	struct lvresize_params lp = { 0 };
 	int ret = ECMD_FAILED;
 
@@ -215,5 +215,6 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 			      &_lvresize_single);
 
 	destroy_processing_handle(cmd, handle);
+
 	return ret;
 }


