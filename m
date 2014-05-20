From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:53:49 +0000 (UTC)
Subject: master - cleanup: unneeded initialization
Message-ID: <20140520195349.1AF2760190@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2941cffd2c6bf67ea2b47696e0ad111f07cf921d
Commit:        2941cffd2c6bf67ea2b47696e0ad111f07cf921d
Parent:        65b3fe9b058862c09994b98c246faaf7e0c0e0aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 20:10:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:28 2014 +0200

cleanup: unneeded initialization

Move or drop initialization where it is not needed.
---
 tools/lvconvert.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2200ba2..03cd42d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1054,13 +1054,10 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 					  int failed_log, int failed_mirrors,
 					  int *replace_log, int *replace_mirrors)
 {
-	const char *leg_policy = NULL, *log_policy = NULL;
-
+	const char *leg_policy, *log_policy;
 	int force = arg_count(cmd, force_ARG);
 	int yes = arg_count(cmd, yes_ARG);
 
-	*replace_log = *replace_mirrors = 1;
-
 	if (arg_count(cmd, use_policies_ARG)) {
 		leg_policy = find_config_tree_str(cmd, activation_mirror_image_fault_policy_CFG, NULL);
 		log_policy = find_config_tree_str(cmd, activation_mirror_log_fault_policy_CFG, NULL);
@@ -1074,6 +1071,8 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 		return;
 	}
 
+	*replace_log = *replace_mirrors = 1;
+
 	if (yes)
 		return;
 
@@ -1616,8 +1615,8 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 				     struct logical_volume *lv,
 				     struct lvconvert_params *lp)
 {
-	int failed_logs = 0;
-	int failed_mimages = 0;
+	int failed_logs;
+	int failed_mimages;
 	int replace_logs = 0;
 	int replace_mimages = 0;
 	uint32_t log_count;


