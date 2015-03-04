From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  4 Mar 2015 13:39:47 +0000 (UTC)
Subject: master - cleanup: tools: "or use -S for selection" --> "or use --select for selection"
Message-ID: <20150304133947.1E8BE61041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7bfc2cbb565eb668068a091d7c2a7a4f4f2ffcc
Commit:        a7bfc2cbb565eb668068a091d7c2a7a4f4f2ffcc
Parent:        733bfe36f5ba34f11b297e41ec249aaa6b238d7b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 4 14:40:04 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 4 14:40:58 2015 +0100

cleanup: tools: "or use -S for selection" --> "or use --select for selection"

---
 tools/lvchange.c |    2 +-
 tools/lvremove.c |    2 +-
 tools/pvchange.c |    2 +-
 tools/vgexport.c |    2 +-
 tools/vgremove.c |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 0351e4e..5e90adc 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1182,7 +1182,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		cmd->handles_missing_pvs = 1;
 
 	if (!argc && !arg_is_set(cmd, select_ARG)) {
-		log_error("Please give logical volume path(s) or use -S for selection.");
+		log_error("Please give logical volume path(s) or use --select for selection.");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/lvremove.c b/tools/lvremove.c
index df920fb..ce0b65b 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -19,7 +19,7 @@ int lvremove(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (!argc && !arg_is_set(cmd, select_ARG)) {
 		log_error("Please enter one or more logical volume paths "
-			  "or use -S for selection.");
+			  "or use --select for selection.");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 3eb9e96..3e0894f 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -180,7 +180,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	handle->custom_handle = &params;
 
 	if (!(arg_count(cmd, all_ARG)) && !argc && !handle->internal_report_for_select) {
-		log_error("Please give a physical volume path or use -S for selection.");
+		log_error("Please give a physical volume path or use --select for selection.");
 		ret = EINVALID_CMD_LINE;
 		goto out;
 	}
diff --git a/tools/vgexport.c b/tools/vgexport.c
index 4bed421..6d5b4f6 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -53,7 +53,7 @@ bad:
 int vgexport(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (!argc && !arg_count(cmd, all_ARG) && !arg_is_set(cmd, select_ARG)) {
-		log_error("Please supply volume groups or use -S for selection or use -a for all.");
+		log_error("Please supply volume groups or use --select for selection or use -a for all.");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/vgremove.c b/tools/vgremove.c
index d33ab1b..fd97356 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -85,7 +85,7 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!argc && !arg_is_set(cmd, select_ARG)) {
 		log_error("Please enter one or more volume group paths "
-			  "or use -S for selection.");
+			  "or use --select for selection.");
 		return EINVALID_CMD_LINE;
 	}
 


