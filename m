From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:04 +0000 (UTC)
Subject: master - lvcreate: reuse validation of names
Message-ID: <20141006133304.2A75D609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20803f2275d9eb08344c4882e62381cf23454eba
Commit:        20803f2275d9eb08344c4882e62381cf23454eba
Parent:        0662391ff60c5fbdf4b941bad92de31558ecd89b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 19:04:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:06 2014 +0200

lvcreate: reuse validation of names

Use validate_lvname_param() for name validation.
---
 tools/lvcreate.c |  111 ++++++++++++++++++++----------------------------------
 1 files changed, 41 insertions(+), 70 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index a3f07f3..3db2c85 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -50,28 +50,14 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 	char **argv = *pargv, *ptr;
 	const char *vg_name;
 
-	lp->pool = arg_str_value(cmd, thinpool_ARG, NULL);
-
-	/* If --thinpool contains VG name, extract it. */
-	if (lp->pool && strchr(lp->pool, '/')) {
-		if (!(lp->vg_name = extract_vgname(cmd, lp->pool)))
-			return 0;
-		/* Strip VG from pool */
-		if ((ptr = strrchr(lp->pool, (int) '/')))
-			lp->pool = ptr + 1;
-	}
-
 	lp->lv_name = arg_str_value(cmd, name_ARG, NULL);
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->lv_name))
+		return_0;
 
-	/* If --name contains VG name, extract it. */
-	if (lp->lv_name && strchr(lp->lv_name, '/')) {
-		if (!_set_vg_name(lp, extract_vgname(cmd, lp->lv_name)))
-			return_0;
-
-		/* Strip VG from lv_name */
-		if ((ptr = strrchr(lp->lv_name, (int) '/')))
-			lp->lv_name = ptr + 1;
-	}
+	lp->pool = arg_str_value(cmd, thinpool_ARG, NULL)
+		? : arg_str_value(cmd, cachepool_ARG, NULL);
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool))
+		return_0;
 
 	if (seg_is_cache(lp)) {
 		/*
@@ -112,22 +98,16 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 		lp->cache = 1;
 		(*pargv)++, (*pargc)--;
 	} else if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
-		/* argv[0] might be origin or vg/origin */
+		/* argv[0] might be [vg/]origin */
 		if (!argc) {
 			log_error("Please specify a logical volume to act as "
 				  "the snapshot origin.");
 			return 0;
 		}
 
-		lp->origin = skip_dev_dir(cmd, argv[0], NULL);
-		if (strrchr(lp->origin, '/')) {
-			if (!_set_vg_name(lp, extract_vgname(cmd, lp->origin)))
-				return_0;
-
-			/* Strip the volume group from the origin */
-			if ((ptr = strrchr(lp->origin, (int) '/')))
-				lp->origin = ptr + 1;
-		}
+		lp->origin = argv[0];
+		if (!validate_lvname_param(cmd, &lp->vg_name, &lp->origin))
+			return_0;
 
 		if (!lp->vg_name &&
 		    !_set_vg_name(lp, extract_vgname(cmd, NULL)))
@@ -140,33 +120,35 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 		}
 
 		(*pargv)++, (*pargc)--;
-	} else if (seg_is_thin(lp) && !lp->pool && argc) {
-		/* argv[0] might be vg or vg/Pool */
+	} else if ((seg_is_thin(lp) || seg_is_pool(lp)) && argc) {
+		/* argv[0] might be [/dev.../]vg or [/dev../]vg/pool */
 
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
-		if (!strrchr(vg_name, '/')) {
+		if (!strchr(vg_name, '/')) {
 			if (!_set_vg_name(lp, vg_name))
 				return_0;
 		} else {
-			lp->pool = vg_name;
-			if (!_set_vg_name(lp, extract_vgname(cmd, lp->pool)))
+			if (!validate_lvname_param(cmd, &lp->vg_name, &vg_name))
 				return_0;
 
+			if (lp->pool &&
+			    (strcmp(vg_name, lp->pool) != 0)) {
+				log_error("Ambiguous %s name specified, %s and %s.",
+					  lp->segtype->name, vg_name, lp->pool);
+				return 0;
+			}
+			lp->pool = vg_name;
+
 			if (!lp->vg_name &&
 			    !_set_vg_name(lp, extract_vgname(cmd, NULL)))
 				return_0;
 
 			if (!lp->vg_name) {
-				log_error("The pool name should include the "
-					  "volume group.");
+				log_error("The %s name should include the "
+					  "volume group.", lp->segtype->name);
 				return 0;
 			}
-
-			/* Strip the volume group */
-			if ((ptr = strrchr(lp->pool, (int) '/')))
-				lp->pool = ptr + 1;
 		}
-
 		(*pargv)++, (*pargc)--;
 	} else {
 		/*
@@ -179,7 +161,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 			}
 		} else {
 			vg_name = skip_dev_dir(cmd, argv[0], NULL);
-			if (strrchr(vg_name, '/')) {
+			if (strchr(vg_name, '/')) {
 				log_error("Volume group name expected "
 					  "(no slash)");
 				return 0;
@@ -192,38 +174,27 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 		}
 	}
 
-	if (!validate_name(lp->vg_name)) {
-		log_error("Volume group name %s has invalid characters",
-			  lp->vg_name);
-		return 0;
-	}
-
-	if (lp->lv_name) {
-		if (!apply_lvname_restrictions(lp->lv_name))
-			return_0;
-
-		if (!validate_name(lp->lv_name)) {
-			log_error("Logical volume name \"%s\" is invalid",
-				  lp->lv_name);
+	/* support --name & --type {thin|cache}-pool */
+	if (seg_is_pool(lp) && lp->lv_name) {
+		if (lp->pool && (strcmp(lp->lv_name, lp->pool) != 0)) {
+			log_error("Ambiguous %s name specified, %s and %s.",
+				  lp->segtype->name, lp->lv_name, lp->pool);
 			return 0;
 		}
+		lp->pool = lp->lv_name;
+		lp->lv_name = NULL;
 	}
 
-	if (lp->pool) {
-		if (!apply_lvname_restrictions(lp->pool))
-			return_0;
-
-		if (!validate_name(lp->pool)) {
-			log_error("Logical volume name \"%s\" is invalid",
-				  lp->pool);
-			return 0;
-		}
+	if (lp->pool && lp->lv_name && !strcmp(lp->pool, lp->lv_name)) {
+		log_error("Logical volume name %s and pool name must be different.",
+			  lp->lv_name);
+		return 0;
+	}
 
-		if (lp->lv_name && !strcmp(lp->lv_name, lp->pool)) {
-			log_error("Logical volume name %s and pool name %s must be different.", 
-				  lp->lv_name, lp->pool);
-			return 0;
-		}
+	if (!validate_name(lp->vg_name)) {
+		log_error("Volume group name %s has invalid characters",
+			  lp->vg_name);
+		return 0;
 	}
 
 	return 1;


