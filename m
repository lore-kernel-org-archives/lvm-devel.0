From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Oct 2014 13:57:04 +0000 (UTC)
Subject: master - lvcreate: regression fix on lv name limits
Message-ID: <20141007135704.008B260EF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0cbb381e159f0606ec749697a596d2a6cc814283
Commit:        0cbb381e159f0606ec749697a596d2a6cc814283
Parent:        27ff61d012740dcdb8f5cf6421c22f746d056fe1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 7 15:41:54 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 7 15:52:31 2014 +0200

lvcreate: regression fix on lv name limits

When we are given an existing LV name - it needs to be allowed
to pass in even restricted name as the LV could have existed
long before we introduced some new restriction on prefix/suffix.i

Fix the regression on name limits and drop restriction to be applied
on any existing LVs - only the new created LV names have to be
complient with current name restrictions.

FIXME: we are currently using restricted names incorrectly in few
other places - device_is_usable() skips restricted names,
and udev flags are also incorrectly set for restricted names
so these LVs are not getting links properly.
---
 lib/metadata/lv_manip.c |    6 ++++++
 tools/lvcreate.c        |    3 +++
 tools/toollib.c         |    3 ---
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 892f7ca..f14cec0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7172,6 +7172,9 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 			    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
 				return_NULL;
 
+			if (lp->pool_name && !apply_lvname_restrictions(lp->pool_name))
+				return_NULL;
+
 			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
 				return_NULL;
 
@@ -7188,6 +7191,9 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 								    "cache-pool")))
 				return_NULL;
 
+			if (lp->pool_name && !apply_lvname_restrictions(lp->pool_name))
+				return_NULL;
+
 			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
 				return_NULL;
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2fa7918..41b8ee3 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -54,6 +54,9 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->lv_name))
 		return_0;
 
+	if (lp->lv_name && !apply_lvname_restrictions(lp->lv_name))
+		return_0;
+
 	lp->pool_name = arg_str_value(cmd, thinpool_ARG, NULL)
 		? : arg_str_value(cmd, cachepool_ARG, NULL);
 	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_name))
diff --git a/tools/toollib.c b/tools/toollib.c
index 1ee8469..3b1b00f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1300,9 +1300,6 @@ int validate_lvname_param(struct cmd_context *cmd, const char **vg_name,
 		*lv_name = lvname;
 	}
 
-	if (!apply_lvname_restrictions(*lv_name))
-		return_0;
-
 	if (!validate_name(*lv_name)) {
 		log_error("Logical volume name \"%s\" is invalid.",
 			  *lv_name);


