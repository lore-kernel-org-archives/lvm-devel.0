From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:55:57 +0000 (UTC)
Subject: master - cleanup: get rid of compiler's warning about possible unitialized variable
Message-ID: <20130306115557.99455A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b777ccbb5dca4a6d80b8b0bf071993c049f6a9f
Commit:        6b777ccbb5dca4a6d80b8b0bf071993c049f6a9f
Parent:        f88690221bb23668e0b763d212b58eeaaa4150a4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 6 12:53:27 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 12:53:27 2013 +0100

cleanup: get rid of compiler's warning about possible unitialized variable

---
 tools/dumpconfig.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index a340eb0..9ba451e 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -37,7 +37,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	const char *type = arg_str_value(cmd, configtype_ARG, "current");
 	unsigned int major, minor, patchlevel;
 	struct config_def_tree_spec tree_spec = {0};
-	struct dm_config_tree *cft;
+	struct dm_config_tree *cft = cmd->cft;
 	int r = ECMD_PROCESSED;
 
 	if (arg_count(cmd, configtype_ARG) && arg_count(cmd, validate_ARG)) {
@@ -71,7 +71,6 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 			log_error("--atversion has no effect with --type current");
 			return EINVALID_CMD_LINE;
 		}
-		cft = cmd->cft;
 		tree_spec.type = CFG_DEF_TREE_CURRENT;
 		config_def_check(cmd, 1, 1, 1);
 	}


