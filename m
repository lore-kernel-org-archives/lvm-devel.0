From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:42 +0000 (UTC)
Subject: master - cleanup: move test for free arg
Message-ID: <20140815130742.2424F61146@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=338b991e4072734a4c37573d1bb541ecadee93b8
Commit:        338b991e4072734a4c37573d1bb541ecadee93b8
Parent:        6872adc0ff7e6c72cc94fd15ed5dd910b958386e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 13 14:19:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:44 2014 +0200

cleanup: move test for free arg

Move test for list of volumes into common place.
---
 tools/lvconvert.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e369def..9c25bd9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -110,8 +110,13 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	char *ptr;
 	const char *vg_name = NULL;
 
-	if (lp->merge)
+	if (lp->merge) {
+		if (!*pargc) {
+			log_error("Please specify a logical volume path.");
+			return 0;
+		}
 		return 1;
+	}
 
 	if (!*pargc) {
 		if (lp->cache) {
@@ -3317,14 +3322,9 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (lp.merge) {
-		if (!argc) {
-			log_error("Please provide logical volume path");
-			return EINVALID_CMD_LINE;
-		}
+	if (lp.merge)
 		return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, &lp,
 				       &_lvconvert_merge_single);
-	}
 
 	return lvconvert_single(cmd, &lp);
 }


