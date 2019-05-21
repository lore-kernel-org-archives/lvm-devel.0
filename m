From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 May 2019 13:21:25 -0400
Subject: master - move the setting of use_full_md_check flag
Message-ID: <201905211721.x4LHLP8p013696@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6422b9ddc5c46968e2bef6ced12cd38e0b44c49d
Commit:        6422b9ddc5c46968e2bef6ced12cd38e0b44c49d
Parent:        19ef399ea781c2c74d0bc8de92f673648d190016
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 21 11:51:58 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 21 11:51:58 2019 -0500

move the setting of use_full_md_check flag

from each command to one location in command init.
No functional change.
---
 tools/lvmcmdline.c |   18 ++++++++++++++++++
 tools/pvcreate.c   |    3 ---
 tools/vgcreate.c   |    3 ---
 tools/vgextend.c   |    3 ---
 4 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0422613..79de85b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2766,6 +2766,22 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 	return 1;
 }
 
+static void _init_md_checks(struct cmd_context *cmd)
+{
+	/*
+	 * use_full_md_check can also be set later.
+	 * These commands are chosen to always perform
+	 * a full md component check because they initialize
+	 * a new device that could be an md component,
+	 * and they are not run frequently during normal
+	 * operation.
+	 */
+	if (!strcmp(cmd->name, "pvcreate") ||
+	    !strcmp(cmd->name, "vgcreate") ||
+	    !strcmp(cmd->name, "vgextend"))
+		cmd->use_full_md_check = 1;
+}
+
 static int _cmd_no_meta_proc(struct cmd_context *cmd)
 {
 	return cmd->cname->flags & NO_METADATA_PROCESSING;
@@ -2979,6 +2995,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
+	_init_md_checks(cmd);
+
 	if (!_cmd_no_meta_proc(cmd) && !_init_lvmlockd(cmd)) {
 		ret = ECMD_FAILED;
 		goto_out;
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 5b59a79..29ae0fa 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -136,9 +136,6 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	pp.pv_count = argc;
 	pp.pv_names = argv;
 
-	/* Check for old md signatures at the end of devices. */
-	cmd->use_full_md_check = 1;
-
 	/* Needed to change the set of orphan PVs. */
 	if (!lock_global(cmd, "ex"))
 		return_ECMD_FAILED;
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 626cf15..6640b8e 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -63,9 +63,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	clear_hint_file(cmd);
 
-	/* Check for old md signatures at the end of devices. */
-	cmd->use_full_md_check = 1;
-
 	/*
 	 * Check if the VG name already exists.  This should be done before
 	 * creating PVs on any of the devices.
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 785be3f..e50a818 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -154,9 +154,6 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	/* pvcreate within vgextend cannot be forced. */
 	pp->force = 0;
 
-	/* Check for old md signatures at the end of devices. */
-	cmd->use_full_md_check = 1;
-
 	if (!lock_global(cmd, "ex"))
 		return_ECMD_FAILED;
 


