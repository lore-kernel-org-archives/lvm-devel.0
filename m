From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 28 Sep 2014 11:56:48 +0000 (UTC)
Subject: master - cleanup: drop unused variable
Message-ID: <20140928115648.C965A600CB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3e9ff7179303cb23ee78819a0c24fc1ccc5394f
Commit:        f3e9ff7179303cb23ee78819a0c24fc1ccc5394f
Parent:        ad60805ffd6a2a5a52c81bc52d818098f674f44e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 27 20:43:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 28 13:49:01 2014 +0200

cleanup: drop unused variable

---
 tools/lvresize.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index c5f01da..133cc6f 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -20,7 +20,6 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 {
 	const char *cmd_name;
 	char *st;
-	unsigned dev_dir_found = 0;
 	int use_policy = arg_count(cmd, use_policies_ARG);
 
 	lp->sign = SIGN_NONE;
@@ -106,7 +105,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	argv++;
 	argc--;
 
-	if (!(lp->lv_name = skip_dev_dir(cmd, lp->lv_name, &dev_dir_found)) ||
+	if (!(lp->lv_name = skip_dev_dir(cmd, lp->lv_name, NULL)) ||
 	    !(lp->vg_name = extract_vgname(cmd, lp->lv_name))) {
 		log_error("Please provide a volume group name");
 		return 0;


