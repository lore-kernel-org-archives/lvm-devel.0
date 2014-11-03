From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:24:01 +0000 (UTC)
Subject: master - cleanup: standard params ordering
Message-ID: <20141103132401.8A1E260243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=228e7ff767b916a033da6d83cfa6970c5cfaba00
Commit:        228e7ff767b916a033da6d83cfa6970c5cfaba00
Parent:        a0f7d6e36a27a3fc38307ae726583cc2e4c2a105
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 11:31:22 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:34 2014 +0100

cleanup: standard params ordering

Pass lvconvert_params as last arg.
---
 tools/lvconvert.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f2eb5f5..22058ea 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -231,8 +231,8 @@ static int _mirror_or_raid_type_requested(struct cmd_context *cmd, const char *t
 	return (arg_count(cmd, mirrors_ARG) || !strncmp(type_str, "raid", 4) || !strcmp(type_str, "mirror"));
 }
 
-static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cmd,
-			     const char *type_str, int *pargc, char ***pargv)
+static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
+			     const char *type_str, struct lvconvert_params *lp)
 {
 	int cachepool = 0;
 	int thinpool = 0;
@@ -339,8 +339,8 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 	return 1;
 }
 
-static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
-			int argc, char **argv)
+static int _read_params(struct cmd_context *cmd, int argc, char **argv,
+			struct lvconvert_params *lp)
 {
 	int i;
 	const char *tmp_str;
@@ -447,7 +447,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		type_str = "thin";
 	}
 
-	if (!_read_pool_params(lp, cmd, type_str, &argc, &argv))
+	if (!_read_pool_params(cmd, &argc, &argv, type_str, lp))
 		return_0;
 
 	if (!arg_count(cmd, background_ARG))
@@ -3509,7 +3509,7 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		.target_attr = ~0,
 	};
 
-	if (!_read_params(&lp, cmd, argc, argv)) {
+	if (!_read_params(cmd, argc, argv, &lp)) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}


