From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 29 Mar 2017 18:39:20 -0400
Subject: master - vgrename: use long enough buffer for path
Message-ID: <201703292239.v2TMdKZN015980@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dfdd6ccf3be73a2b22743ea1df31cd3d7e3c9095
Commit:        dfdd6ccf3be73a2b22743ea1df31cd3d7e3c9095
Parent:        4b3d71212fb07c945acebb074820a63e970504e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 30 00:17:37 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 30 00:38:41 2017 +0200

vgrename: use long enough buffer for path

Use PATH_MAX when creating buffers for rename.
---
 WHATS_NEW                    |    1 +
 daemons/cmirrord/functions.c |    2 +-
 tools/vgrename.c             |   12 ++++++++----
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6349468..abff1c8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.170 - 
 ==================================
+  Check and use PATH_MAX buffers when creating vgrename device paths.
 
 Version 2.02.169 - 28th March 2017
 ==================================
diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 5e50b8a..03f8626 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -377,7 +377,7 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 	uint32_t block_on_error = 0;
 
 	int disk_log;
-	char disk_path[128];
+	char disk_path[PATH_MAX];
 	int unlink_path = 0;
 	long page_size;
 	int pages;
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 293f63c..5c69faf 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -38,8 +38,8 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg, struct processing_handle *handle)
 {
 	struct vgrename_params *vp = (struct vgrename_params *) handle->custom_handle;
-	char old_path[NAME_LEN];
-	char new_path[NAME_LEN];
+	char old_path[PATH_MAX];
+	char new_path[PATH_MAX];
 	struct id id;
 	const char *name;
 	char *dev_dir;
@@ -136,8 +136,12 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 		goto error;
 	}
 
-	sprintf(old_path, "%s%s", dev_dir, vg_name);
-	sprintf(new_path, "%s%s", dev_dir, vp->vg_name_new);
+	if ((dm_snprintf(old_path, sizeof(old_path), "%s%s", dev_dir, vg_name) < 0) ||
+	    (dm_snprintf(new_path, sizeof(new_path), "%s%s", dev_dir, vp->vg_name_new) < 0)) {
+		log_error("Renaming path is too long %s/%s  %s/%s",
+			  dev_dir, vg_name, dev_dir, vp->vg_name_new);
+		goto error;
+	}
 
 	if (activation() && dir_exists(old_path)) {
 		log_verbose("Renaming \"%s\" to \"%s\"", old_path, new_path);


