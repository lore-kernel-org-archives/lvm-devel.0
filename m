From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:04:17 +0000 (GMT)
Subject: main - cleanup: simply code
Message-ID: <20210223140417.8B7223939C01@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5f906e984abea169209302b78bfa935869d6ea4
Commit:        b5f906e984abea169209302b78bfa935869d6ea4
Parent:        5ecd65e6f2f5264b0ebe1177a714bc8d29e882fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 20 22:11:30 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:56:48 2021 +0100

cleanup: simply code

---
 tools/lvresize.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 0c72a81ff..a3c17a744 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -146,14 +146,6 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->argc = --argc;
 	lp->argv = ++argv;
 
-	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, 0);
-	lp->yes = arg_is_set(cmd, yes_ARG);
-	lp->force = arg_is_set(cmd, force_ARG);
-	lp->nofsck = arg_is_set(cmd, nofsck_ARG);
-	lp->nosync = arg_is_set(cmd, nosync_ARG);
-	lp->resizefs = arg_is_set(cmd, resizefs_ARG);
-	lp->lockopt = arg_str_value(cmd, lockopt_ARG, NULL);
-
 	return 1;
 }
 
@@ -186,7 +178,15 @@ out:
 int lvresize(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
-	struct lvresize_params lp = { 0 };
+	struct lvresize_params lp = {
+		.alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, 0),
+		.yes = arg_is_set(cmd, yes_ARG),
+		.force = arg_is_set(cmd, force_ARG),
+		.nofsck = arg_is_set(cmd, nofsck_ARG),
+		.nosync = arg_is_set(cmd, nosync_ARG),
+		.resizefs = arg_is_set(cmd, resizefs_ARG),
+		.lockopt = arg_str_value(cmd, lockopt_ARG, NULL),
+	};
 	int ret;
 
 	if (!_lvresize_params(cmd, argc, argv, &lp)) {


