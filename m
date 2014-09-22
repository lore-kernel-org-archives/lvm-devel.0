From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:46 +0000 (UTC)
Subject: dev-dct-process-latest - fix: regression for recent persistent commit
Message-ID: <20140922153946.AE8406092E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=392bb6f46eb73dcf725566fbdf006a4e02ae7502
Commit:        392bb6f46eb73dcf725566fbdf006a4e02ae7502
Parent:        18b8fdc8c92f54c39b8089c343d6fc12fafd1f38
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 17:05:35 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 17:08:41 2014 +0200

fix: regression for recent persistent commit

Do not let fly metadata with just 'minor' set
(since they would not be readable on older version)

Be permissive with invalid major/minor number and
just report them as problem, but allow to use
such metadata with default major:minor.
---
 lib/format_text/import_vsn1.c |   17 ++++++++++-------
 tools/lvmcmdline.c            |   12 +++++++-----
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 580349f..1783b1e 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -678,16 +678,19 @@ static int _read_lvsegs(struct format_instance *fid,
 			return 0;
 		}
 
-		if (!_read_int32(lvn, "major", &lv->major)) {
-			log_error("Couldn't read major number for logical "
-				  "volume %s.", lv->name);
-			return 0;
+		if (!dm_config_has_node(lvn, "major"))
+			/* If major is missing, pick default */
+			lv->major = vg->cmd->dev_types->device_mapper_major;
+		else if (!_read_int32(lvn, "major", &lv->major)) {
+			log_warn("WARNING: Couldn't read major number for logical "
+				 "volume %s.", lv->name);
+			lv->major = vg->cmd->dev_types->device_mapper_major;
 		}
 
 		if (!validate_major_minor(vg->cmd, fid->fmt, lv->major, lv->minor)) {
-			log_error("Logical volume %s does not have a valid major, minor number.",
-				  lv->name);
-			return 0;
+			log_warn("WARNING: Ignoring invalid major, minor number for "
+				 "logical volume %s.", lv->name);
+			lv->major = lv->minor = -1;
 		}
 	}
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9a5cc3a..5f258a2 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -607,11 +607,13 @@ int read_and_validate_major_minor(const struct cmd_context *cmd,
 			return 0;
 		}
 		*major = arg_int_value(cmd, major_ARG, -1);
-	} else if (arg_is_set(cmd, major_ARG)) {
-		log_warn("WARNING: Ignoring supplied major number - "
-			 "kernel assigns major numbers dynamically. "
-			 "Using major number %d instead.",
-			 cmd->dev_types->device_mapper_major);
+	} else {
+		if (arg_is_set(cmd, major_ARG)) {
+			log_warn("WARNING: Ignoring supplied major number - "
+				 "kernel assigns major numbers dynamically. "
+				 "Using major number %d instead.",
+				 cmd->dev_types->device_mapper_major);
+		}
 		*major = cmd->dev_types->device_mapper_major;
 	}
 


