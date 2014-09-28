From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 28 Sep 2014 11:56:38 +0000 (UTC)
Subject: master - toollib: refactor skip_dev_dir
Message-ID: <20140928115638.5B46860041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b0dde9e8f026ddd6799d6ca534ff9523d633c735
Commit:        b0dde9e8f026ddd6799d6ca534ff9523d633c735
Parent:        f120c954fc065d67c1aacd5cfba58843eb552b0f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 28 12:54:20 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 28 13:49:01 2014 +0200

toollib: refactor skip_dev_dir

Detect dev dir just once.
---
 tools/toollib.c |   62 +++++++++++++++++++++++++++---------------------------
 1 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 7be5b5a..3a0e053 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -108,51 +108,51 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 			 unsigned *dev_dir_found)
 {
-	const char *dmdir = dm_dir();
+	size_t devdir_len = strlen(cmd->dev_dir);
+	const char *dmdir = dm_dir() + devdir_len;
 	size_t dmdir_len = strlen(dmdir), vglv_sz;
 	char *vgname, *lvname, *layer, *vglv;
 
 	/* FIXME Do this properly */
-	if (*vg_name == '/') {
-		while (*vg_name == '/')
+	if (*vg_name == '/')
+		while (vg_name[1] == '/')
 			vg_name++;
-		vg_name--;
-	}
 
-	/* Reformat string if /dev/mapper found */
-	if (!strncmp(vg_name, dmdir, dmdir_len) && vg_name[dmdir_len] == '/') {
+	if (strncmp(vg_name, cmd->dev_dir, devdir_len)) {
+		if (dev_dir_found)
+			*dev_dir_found = 0;
+	} else {
 		if (dev_dir_found)
 			*dev_dir_found = 1;
-		vg_name += dmdir_len;
+
+		vg_name += devdir_len;
 		while (*vg_name == '/')
 			vg_name++;
 
-		if (!dm_split_lvm_name(cmd->mem, vg_name, &vgname, &lvname, &layer) ||
-		    *layer) {
-			log_error("skip_dev_dir: Couldn't split up device name %s",
-				  vg_name);
-			return vg_name;
-		}
-		vglv_sz = strlen(vgname) + strlen(lvname) + 2;
-		if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
-		    dm_snprintf(vglv, vglv_sz, "%s%s%s", vgname,
-				 *lvname ? "/" : "",
-				 lvname) < 0) {
-			log_error("vg/lv string alloc failed");
-			return vg_name;
+		/* Reformat string if /dev/mapper found */
+		if (!strncmp(vg_name, dmdir, dmdir_len) && vg_name[dmdir_len + 1] == '/') {
+			vg_name += devdir_len + 1;
+			while (*vg_name == '/')
+				vg_name++;
+
+			if (!dm_split_lvm_name(cmd->mem, vg_name, &vgname, &lvname, &layer) ||
+			    *layer) {
+				log_error("skip_dev_dir: Couldn't split up device name %s",
+					  vg_name);
+				return vg_name;
+			}
+			vglv_sz = strlen(vgname) + strlen(lvname) + 2;
+			if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
+			    dm_snprintf(vglv, vglv_sz, "%s%s%s", vgname,
+					*lvname ? "/" : "",
+					lvname) < 0) {
+				log_error("vg/lv string alloc failed");
+				return vg_name;
+			}
+			return vglv;
 		}
-		return vglv;
 	}
 
-	if (!strncmp(vg_name, cmd->dev_dir, strlen(cmd->dev_dir))) {
-		if (dev_dir_found)
-			*dev_dir_found = 1;
-		vg_name += strlen(cmd->dev_dir);
-		while (*vg_name == '/')
-			vg_name++;
-	} else if (dev_dir_found)
-		*dev_dir_found = 0;
-
 	return vg_name;
 }
 


