From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:41 +0000 (UTC)
Subject: master - cleanup: code lines reodered
Message-ID: <20160623130141.4988060612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a525832f9902f6268d155f22975653f27877816
Commit:        0a525832f9902f6268d155f22975653f27877816
Parent:        3a4107c982e706dd97117e7e182bf9cbf7e85cac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 15 11:35:16 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:08 2016 +0200

cleanup: code lines reodered

---
 tools/lvresize.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 9fb35bd..ee6678f 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -18,21 +18,19 @@
 static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 			    struct lvresize_params *lp)
 {
-	const char *cmd_name;
+	const char *cmd_name = command_name(cmd);
 	char *st;
-	int use_policy = arg_is_set(cmd, usepolicies_ARG);
 
-	lp->sign = SIGN_NONE;
-	lp->poolmetadatasign = SIGN_NONE;
-	lp->resize = LV_ANY;
-
-	cmd_name = command_name(cmd);
 	if (!strcmp(cmd_name, "lvreduce"))
 		lp->resize = LV_REDUCE;
-	if (!strcmp(cmd_name, "lvextend"))
+	else if (!strcmp(cmd_name, "lvextend"))
 		lp->resize = LV_EXTEND;
+	else
+		lp->resize = LV_ANY;
+
+	lp->sign = lp->poolmetadatasign = SIGN_NONE;
 
-	if (use_policy) {
+	if ((lp->ac_policy = arg_is_set(cmd, usepolicies_ARG))) {
 		/* do nothing; _lvresize will handle --use-policies itself */
 		lp->extents = 0;
 		lp->sign = SIGN_PLUS;


