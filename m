From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:44 +0000 (UTC)
Subject: master - cleanup: simplier struct initilization
Message-ID: <20140815130744.4DEE161146@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5095a6517da9b57b0d2540b961e9841ad02fa8cc
Commit:        5095a6517da9b57b0d2540b961e9841ad02fa8cc
Parent:        338b991e4072734a4c37573d1bb541ecadee93b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 13 14:20:10 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:44 2014 +0200

cleanup: simplier struct initilization

---
 tools/lvconvert.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9c25bd9..d9fc749 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -348,9 +348,6 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	int pagesize = lvm_getpagesize();
 	const char *type_str = arg_str_value(cmd, type_ARG, "");
 
-	memset(lp, 0, sizeof(*lp));
-	lp->target_attr = ~0;
-
 	if (!_check_conversion_type(cmd, type_str))
 		return_0;
 
@@ -3315,7 +3312,9 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 
 int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 {
-	struct lvconvert_params lp;
+	struct lvconvert_params lp = {
+		.target_attr = ~0,
+	};
 
 	if (!_read_params(&lp, cmd, argc, argv)) {
 		stack;


