From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:30:58 +0100
Subject: [PATCH 12/16] Add missing stacks to toollib.c
In-Reply-To: <cover.1297419991.git.zkabelac@redhat.com>
References: <cover.1297419991.git.zkabelac@redhat.com>
Message-ID: <3dcbca619b42d8b9a8d95ddb110e651f77e0f507.1297419991.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 5467a3b..2a52a51 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -169,8 +169,10 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		}
 		if (ret > ret_max)
 			ret_max = ret;
-		if (sigint_caught())
+		if (sigint_caught()) {
+			stack;
 			return ret_max;
+		}
 	}
 
 	if (lvargs_supplied && lvargs_matched != dm_list_size(arg_lvnames)) {
@@ -253,8 +255,10 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 				while (*lv_name == '/')
 					lv_name++;
 				if (!(vgname = extract_vgname(cmd, vgname))) {
-					if (ret_max < ECMD_FAILED)
+					if (ret_max < ECMD_FAILED) {
+						stack;
 						ret_max = ECMD_FAILED;
+					}
 					continue;
 				}
 			} else if (!dev_dir_found &&
@@ -348,8 +352,10 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 						    tags_arg, &failed_lvnames,
 						    handle, process_single_lv);
 			if (ret != ECMD_PROCESSED ||
-			    dm_list_empty(&failed_lvnames))
+			    dm_list_empty(&failed_lvnames)) {
+				stack;
 				break;
+			}
 
 			/* Try again with failed LVs in this VG */
 			dm_list_init(&lvnames);
@@ -357,6 +363,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 			free_cmd_vgs(&cmd_vgs);
 			if (!cmd_vg_read(cmd, &cmd_vgs)) {
+				stack;
 				ret = ECMD_FAILED; /* break */
 				break;
 			}
@@ -366,8 +373,10 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 		free_cmd_vgs(&cmd_vgs);
 		/* FIXME: logic for breaking command is not consistent */
-		if (sigint_caught())
+		if (sigint_caught()) {
+			stack;
 			return ECMD_FAILED;
+		}
 	}
 
 	return ret_max;
-- 
1.7.4


