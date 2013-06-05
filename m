From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:02:57 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lv: add lv_active_change
Message-ID: <20130605120257.6DA0C60E47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2d71330c308230065dbc865e4552a9a62aad269
Commit:        d2d71330c308230065dbc865e4552a9a62aad269
Parent:        dacc340cc89e9be5cb88986a444466edb3a06e52
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 29 14:04:38 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 15:43:19 2013 +0200

lv: add lv_active_change

Make a separate /lib function for the change of activation state
of the LV.

(in release update)
---
 lib/metadata/lv.c |   37 +++++++++++++++++++++++++++++++++++++
 lib/metadata/lv.h |    6 +++++-
 tools/toollib.c   |   37 ++++---------------------------------
 3 files changed, 46 insertions(+), 34 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 3dbdb38..41de7a5 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -704,6 +704,43 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return dm_pool_strdup(mem, lv->hostname ? : "");
 }
 
+int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
+		     activation_change_t activate)
+{
+	if (activate == CHANGE_AN) {
+		log_verbose("Deactivating logical volume \"%s\"", lv->name);
+		if (!deactivate_lv(cmd, lv))
+			return_0;
+	} else if ((activate == CHANGE_AE) ||
+		   lv_is_origin(lv) ||
+		   lv_is_thin_type(lv)) {
+		if (activate == CHANGE_ALN) {
+			/* origin or thin, all others have _AE */
+			/* other types of activation are implicitly exclusive */
+			/* Note: the order of tests is mandatory */
+			log_error("Cannot deactivate \"%s\" locally.", lv->name);
+			return 0;
+		}
+		log_verbose("Activating logical volume \"%s\" exclusively.", lv->name);
+		if (!activate_lv_excl(cmd, lv))
+			return_0;
+	} else if (activate == CHANGE_ALN) {
+		log_verbose("Deactivating logical volume \"%s\" locally.", lv->name);
+		if (!deactivate_lv_local(cmd, lv))
+			return_0;
+	} else if ((activate == CHANGE_ALY) || (activate == CHANGE_AAY)) {
+		log_verbose("Activating logical volume \"%s\" locally.", lv->name);
+		if (!activate_lv_local(cmd, lv))
+			return_0;
+	} else { /* CHANGE_AY */
+		log_verbose("Activating logical volume \"%s\".", lv->name);
+		if (!activate_lv(cmd, lv))
+			return_0;
+	}
+
+	return 1;
+}
+
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	const char *s;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 9450f8d..bac8bc2 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -20,6 +20,8 @@ struct volume_group;
 struct dm_list;
 struct lv_segment;
 struct replicator_device;
+enum activation_change;
+typedef enum activation_change activation_change_t;
 
 struct logical_volume {
 	union lvid lvid;
@@ -85,5 +87,7 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_set_creation(struct logical_volume *lv,
 		    const char *hostname, uint64_t timestamp);
 const char *lv_layer(const struct logical_volume *lv);
+int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
+		     activation_change_t activate);
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 #endif /* _LVM_LV_H */
diff --git a/tools/toollib.c b/tools/toollib.c
index 950ca33..e9be968 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1300,41 +1300,12 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		       activation_change_t activate)
 {
-	if (activate == CHANGE_AN) {
-		log_verbose("Deactivating logical volume \"%s\"", lv->name);
-		if (!deactivate_lv(cmd, lv))
-			return_0;
-		return 1;
-	} else if ((activate == CHANGE_AE) ||
-		   lv_is_origin(lv) ||
-		   lv_is_thin_type(lv)) {
-		if (activate == CHANGE_ALN) {
-			/* origin or thin, all others have _AE */
-			/* other types of activation are implicitly exclusive */
-			/* Note: the order of tests is mandatory */
-			log_error("Cannot deactivate \"%s\" locally.", lv->name);
-			return 0;
-		}
-		log_verbose("Activating logical volume \"%s\" exclusively.", lv->name);
-		if (!activate_lv_excl(cmd, lv))
-			return_0;
-	} else if (activate == CHANGE_ALN) {
-		log_verbose("Deactivating logical volume \"%s\" locally.", lv->name);
-		if (!deactivate_lv_local(cmd, lv))
-			return_0;
-		return 1;
-	} else if ((activate == CHANGE_ALY) || (activate == CHANGE_AAY)) {
-		log_verbose("Activating logical volume \"%s\" locally.", lv->name);
-		if (!activate_lv_local(cmd, lv))
-			return_0;
-	} else { /* CHANGE_AY */
-		log_verbose("Activating logical volume \"%s\".", lv->name);
-		if (!activate_lv(cmd, lv))
-			return_0;
-	}
+	if (!lv_active_change(cmd, lv, activate))
+		return_0;
 
-	/* CHANGE_AN/ALN is not getting here */
 	if (background_polling() &&
+	    (activate != CHANGE_AN) &&
+	    (activate != CHANGE_ALN) &&
 	    (lv->status & (PVMOVE|CONVERTING|MERGING)))
 		lv_spawn_background_polling(cmd, lv);
 


