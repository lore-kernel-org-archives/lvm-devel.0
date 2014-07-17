From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:06 +0000 (UTC)
Subject: master - lvconvert: move to single name validation
Message-ID: <20140717142906.D991C608F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4dcacbe369346e957398fd4951fc1a6d1fd4560f
Commit:        4dcacbe369346e957398fd4951fc1a6d1fd4560f
Parent:        04acf7a8d0713c858df893584401e96100f9d9d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 17 12:19:48 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:14:36 2014 +0200

lvconvert: move to single name validation

Validate all LV names in _lvconvert_name_params().
---
 tools/lvconvert.c |   19 ++++---------------
 1 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8370b49..6ec7fa5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -146,6 +146,9 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	if (!_lvconvert_vg_name(lp, cmd, &lp->origin_lv_name))
 		return_0;
 
+	if (!_lvconvert_vg_name(lp, cmd, &lp->lv_split_name))
+		return_0;
+
 	if (strchr(lp->lv_name_full, '/') &&
 	    (vg_name = extract_vgname(cmd, lp->lv_name_full)) &&
 	    lp->vg_name && strcmp(vg_name, lp->vg_name)) {
@@ -483,21 +486,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 
-		lp->lv_split_name = arg_value(cmd, name_ARG);
-		if (lp->lv_split_name) {
-			if (strchr(lp->lv_split_name, '/')) {
-				if (!(lp->vg_name = extract_vgname(cmd, lp->lv_split_name)))
-					return_0;
-
-				/* Strip VG from lv_split_name */
-				if ((tmp_str = strrchr(lp->lv_split_name, '/')))
-					lp->lv_split_name = tmp_str + 1;
-			}
-
-			if (!apply_lvname_restrictions(lp->lv_split_name))
-				return_0;
-		}
-
+		lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL);
 		lp->keep_mimages = 1;
 		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);
 		lp->mirrors_sign = SIGN_MINUS;


