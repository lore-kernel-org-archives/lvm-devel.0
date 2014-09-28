From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 28 Sep 2014 11:56:40 +0000 (UTC)
Subject: master - toollib: refactor extract_vgname
Message-ID: <20140928115640.78F5760041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=911d6efa51fac96846e109dbff8839cd3fb6cb25
Commit:        911d6efa51fac96846e109dbff8839cd3fb6cb25
Parent:        b0dde9e8f026ddd6799d6ca534ff9523d633c735
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 27 16:29:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 28 13:49:01 2014 +0200

toollib: refactor extract_vgname

Split internals of extract_vgname into _extract_vgname.
This common code will be used for other similar function.

Reuse skip_dev_dir() instead of less mature coded to skip
device dir.

Instead of duplicating full vg/lv name - allocate string
only vg portion of lv name.
---
 tools/toollib.c |   71 ++++++++++++++++++++++++++----------------------------
 1 files changed, 34 insertions(+), 37 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 3a0e053..31bb037 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -954,52 +954,49 @@ bad:
 	return ECMD_FAILED;
 }
 
+static const char *_extract_vgname(struct cmd_context *cmd, const char *lv_name,
+				   const char **after)
+{
+	const char *vg_name = lv_name;
+	char *st, *pos;
+
+	/* Strip dev_dir (optional) */
+	if (!(vg_name = skip_dev_dir(cmd, vg_name, NULL)))
+		return_0;
+
+	/* Require exactly one set of consecutive slashes */
+	if ((st = pos = strchr(vg_name, '/')))
+		while (*st == '/')
+			st++;
+
+	if (!st || strchr(st, '/')) {
+		log_error("\"%s\": Invalid path for Logical Volume",
+			  lv_name);
+		return 0;
+	}
+
+	if (!(vg_name = dm_pool_strndup(cmd->mem, vg_name, pos - vg_name))) {
+		log_error("Allocation of vg_name failed.");
+		return 0;
+	}
+
+	if (after)
+		*after = st;
+
+	return vg_name;
+}
 /*
  * Determine volume group name from a logical volume name
  */
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 {
 	const char *vg_name = lv_name;
-	char *st;
-	char *dev_dir = cmd->dev_dir;
 
 	/* Path supplied? */
 	if (vg_name && strchr(vg_name, '/')) {
-		/* Strip dev_dir (optional) */
-		if (*vg_name == '/') {
-			while (*vg_name == '/')
-				vg_name++;
-			vg_name--;
-		}
-		if (!strncmp(vg_name, dev_dir, strlen(dev_dir))) {
-			vg_name += strlen(dev_dir);
-			while (*vg_name == '/')
-				vg_name++;
-		}
-		if (*vg_name == '/') {
-			log_error("\"%s\": Invalid path for Logical "
-				  "Volume", lv_name);
-			return 0;
-		}
-
-		/* Require exactly one set of consecutive slashes */
-		if ((st = strchr(vg_name, '/')))
-			while (*st == '/')
-				st++;
-
-		if (!st || strchr(st, '/')) {
-			log_error("\"%s\": Invalid path for Logical Volume",
-				  lv_name);
-			return 0;
-		}
-
-		vg_name = dm_pool_strdup(cmd->mem, vg_name);
-		if (!vg_name) {
-			log_error("Allocation of vg_name failed");
-			return 0;
-		}
+		if (!(vg_name = _extract_vgname(cmd, lv_name, NULL)))
+			return_NULL;
 
-		*strchr(vg_name, '/') = '\0';
 		return vg_name;
 	}
 
@@ -1007,7 +1004,7 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 		if (lv_name)
 			log_error("Path required for Logical Volume \"%s\"",
 				  lv_name);
-		return 0;
+		return NULL;
 	}
 
 	return vg_name;


