From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Oct 2014 09:36:48 +0000 (UTC)
Subject: master - toollib: validate_restricted_lvname_param
Message-ID: <20141008093648.968E86010C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b59335fb398062d6537e8d4e815dcbf339343967
Commit:        b59335fb398062d6537e8d4e815dcbf339343967
Parent:        c87e5a308a95e6e7c2d120ce816df14644f8e70a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 8 11:14:33 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 8 11:35:50 2014 +0200

toollib: validate_restricted_lvname_param

Lets make a separate new function to validate names that has
to follow up restriction rules.
---
 tools/lvconvert.c |    8 ++++----
 tools/lvcreate.c  |    5 +----
 tools/toollib.c   |   19 +++++++++++++++++++
 tools/toollib.h   |    2 ++
 4 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 50410a5..ad4a6c0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -126,16 +126,16 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		(*pargv)++, (*pargc)--;
 	}
 
-	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_metadata_name))
+	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->pool_metadata_name))
 		return_0;
 
-	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_data_name))
+	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->pool_data_name))
 		return_0;
 
-	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin_name))
+	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->origin_name))
 		return_0;
 
-	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->lv_split_name))
+	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->lv_split_name))
 		return_0;
 
 	if (strchr(lp->lv_name_full, '/') &&
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 41b8ee3..5a4bced 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -51,10 +51,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 	const char *vg_name;
 
 	lp->lv_name = arg_str_value(cmd, name_ARG, NULL);
-	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->lv_name))
-		return_0;
-
-	if (lp->lv_name && !apply_lvname_restrictions(lp->lv_name))
+	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->lv_name))
 		return_0;
 
 	lp->pool_name = arg_str_value(cmd, thinpool_ARG, NULL)
diff --git a/tools/toollib.c b/tools/toollib.c
index 8b92968..7f656c6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1309,6 +1309,25 @@ int validate_lvname_param(struct cmd_context *cmd, const char **vg_name,
 	return 1;
 }
 
+/*
+ * Validate lvname parameter
+ * This name must follow restriction rules on prefixes and suffixes.
+ *
+ * If it contains vgname, it is extracted from lvname.
+ * If there is passed vgname, it is compared whether its the same name.
+ */
+int validate_restricted_lvname_param(struct cmd_context *cmd, const char **vg_name,
+				     const char **lv_name)
+{
+	if (!validate_lvname_param(cmd, vg_name, lv_name))
+		return_0;
+
+	if (lv_name && *lv_name && !apply_lvname_restrictions(*lv_name))
+		return_0;
+
+	return -1;
+}
+
 struct vgnameid_list {
 	struct dm_list list;
 	const char *vg_name;
diff --git a/tools/toollib.h b/tools/toollib.h
index 037b7d7..50cc26c 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -132,6 +132,8 @@ int get_and_validate_major_minor(const struct cmd_context *cmd,
 
 int validate_lvname_param(struct cmd_context *cmd, const char **vg_name,
 			  const char **lv_name);
+int validate_restricted_lvname_param(struct cmd_context *cmd, const char **vg_name,
+				     const char **lv_name);
 
 int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
                     void *handle __attribute__((unused)));


