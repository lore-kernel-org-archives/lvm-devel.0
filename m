From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 17 Oct 2012 13:43:26 +0000 (UTC)
Subject: master - cleanup: move log_error upward in code stack
Message-ID: <20121017134326.8DCC91F38@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e431b19bac29cf8fc21530118eb283b6ae703cbb
Commit:        e431b19bac29cf8fc21530118eb283b6ae703cbb
Parent:        f260f99d5791791f0aef2172b199fa5cdb7f6102
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 10:20:02 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 17 15:41:44 2012 +0200

cleanup: move log_error upward in code stack

Report log_error earlier.
---
 lib/metadata/metadata.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0b3158a..549a356 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -450,8 +450,11 @@ static int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
 {
 	static char vg_path[PATH_MAX];
 
-	if (!validate_name(vg_name))
-		return_0;
+	if (!validate_name(vg_name)) {
+		log_error("New volume group name \"%s\" is invalid.",
+			  vg_name);
+		return 0;
+	}
 
 	snprintf(vg_path, sizeof(vg_path), "%s%s", cmd->dev_dir, vg_name);
 	if (path_exists(vg_path)) {
@@ -479,11 +482,8 @@ int validate_vg_rename_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!validate_new_vg_name(cmd, vg_name_new)) {
-		log_error("New volume group name \"%s\" is invalid",
-			  vg_name_new);
-		return 0;
-	}
+	if (!validate_new_vg_name(cmd, vg_name_new))
+		return_0;
 
 	if (!strcmp(vg_name_old, vg_name_new)) {
 		log_error("Old and new volume group names must differ");
@@ -819,11 +819,8 @@ const char *strip_dir(const char *vg_name, const char *dev_dir)
 int vgcreate_params_validate(struct cmd_context *cmd,
 			     struct vgcreate_params *vp)
 {
-	if (!validate_new_vg_name(cmd, vp->vg_name)) {
-		log_error("New volume group name \"%s\" is invalid",
-			  vp->vg_name);
-		return 0;
-	}
+	if (!validate_new_vg_name(cmd, vp->vg_name))
+		return_0;
 
 	if (vp->alloc == ALLOC_INHERIT) {
 		log_error("Volume Group allocation policy cannot inherit "


