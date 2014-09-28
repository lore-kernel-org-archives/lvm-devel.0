From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 28 Sep 2014 11:56:46 +0000 (UTC)
Subject: master - lvconvert: switch to validate_lvname_param
Message-ID: <20140928115646.B748B60041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ad60805ffd6a2a5a52c81bc52d818098f674f44e
Commit:        ad60805ffd6a2a5a52c81bc52d818098f674f44e
Parent:        0d4baeba18646478e1edb7b26a9f9c74d6add1f5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 28 13:07:18 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 28 13:49:01 2014 +0200

lvconvert: switch to validate_lvname_param

Use new toollib function for validation.
---
 tools/lvconvert.c |   39 ++++-----------------------------------
 1 files changed, 4 insertions(+), 35 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 28a3526..c05ea1b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -72,37 +72,6 @@ struct lvconvert_params {
 	thin_discards_t discards;
 };
 
-static int _lvconvert_vg_name(struct lvconvert_params *lp,
-			      struct cmd_context *cmd,
-			      const char **lv_name)
-{
-	const char *vg_name;
-	const char *tmp_str;
-
-	if (!lv_name || !*lv_name)
-		return 1;
-
-	/* If contains VG name, extract it. */
-	if ((tmp_str = strchr(*lv_name, (int) '/'))) {
-		if (!(vg_name = extract_vgname(cmd, *lv_name)))
-			return_0;
-		if (!lp->vg_name)
-			lp->vg_name = vg_name;
-		else if (strcmp(vg_name, lp->vg_name)) {
-			log_error("Please use a single volume group name "
-				  "(\"%s\" or \"%s\")", vg_name, lp->vg_name);
-			return 0;
-		}
-		/* Strip VG from lv_name */
-		*lv_name = tmp_str + 1;
-	}
-
-	if (!apply_lvname_restrictions(*lv_name))
-		return_0;
-
-	return 1;
-}
-
 static int _lvconvert_name_params(struct lvconvert_params *lp,
 				  struct cmd_context *cmd,
 				  int *pargc, char ***pargv)
@@ -142,16 +111,16 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		(*pargv)++, (*pargc)--;
 	}
 
-	if (!_lvconvert_vg_name(lp, cmd, &lp->pool_metadata_lv_name))
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_metadata_lv_name))
 		return_0;
 
-	if (!_lvconvert_vg_name(lp, cmd, &lp->pool_data_lv_name))
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_data_lv_name))
 		return_0;
 
-	if (!_lvconvert_vg_name(lp, cmd, &lp->origin_lv_name))
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin_lv_name))
 		return_0;
 
-	if (!_lvconvert_vg_name(lp, cmd, &lp->lv_split_name))
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->lv_split_name))
 		return_0;
 
 	if (strchr(lp->lv_name_full, '/') &&


