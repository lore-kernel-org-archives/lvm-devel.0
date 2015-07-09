From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  9 Jul 2015 20:16:41 +0000 (UTC)
Subject: master - metadata: vg_validate lock_args
Message-ID: <20150709201641.3298F60072@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=841c3478fd1a20560db4ef01bfe30a7f8beb6608
Commit:        841c3478fd1a20560db4ef01bfe30a7f8beb6608
Parent:        6294509cc6a6a4f6150e6f4de84483a7f54ad9b5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 9 13:24:28 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 9 13:25:00 2015 -0500

metadata: vg_validate lock_args

---
 lib/metadata/metadata.c |   91 +++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 84 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 07ef54e..b0aa122 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2484,6 +2484,75 @@ static int _lv_validate_references_single(struct logical_volume *lv, void *data)
 	return r;
 }
 
+/*
+ * Format is <version>:<info>
+ */
+static int _validate_lock_args_chars(const char *lock_args)
+{
+	int i;
+	char c;
+	int found_colon = 0;
+	int r = 1;
+
+	for (i = 0; i < strlen(lock_args); i++) {
+		c = lock_args[i];
+
+		if (!isalnum(c) && c != '.' && c != '_' && c != '-' && c != '+' && c != ':') {
+			log_error(INTERNAL_ERROR "Invalid character at index %d of lock_args \"%s\"",
+				  i, lock_args);
+			r = 0;
+		}
+
+		if (c == ':' && found_colon) {
+			log_error(INTERNAL_ERROR "Invalid colon@index %d of lock_args \"%s\"",
+				  i, lock_args);
+			r = 0;
+		}
+
+		if (c == ':')
+			found_colon = 1;
+	}
+
+	return r;
+}
+
+static int _validate_vg_lock_args(struct volume_group *vg)
+{
+	if (!_validate_lock_args_chars(vg->lock_args)) {
+		log_error(INTERNAL_ERROR "VG %s has invalid lock_args chars", vg->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * For lock_type sanlock, LV lock_args are <version>:<info>
+ * For lock_type dlm, LV lock_args are not used, and lock_args is
+ * just set to "dlm".
+ */
+static int _validate_lv_lock_args(struct logical_volume *lv)
+{
+	int r = 1;
+
+	if (!strcmp(lv->vg->lock_type, "sanlock")) {
+		if (!_validate_lock_args_chars(lv->lock_args)) {
+			log_error(INTERNAL_ERROR "LV %s/%s has invalid lock_args chars",
+				  lv->vg->name, display_lvname(lv));
+			return 0;
+		}
+
+	} else if (!strcmp(lv->vg->lock_type, "dlm")) {
+		if (strcmp(lv->lock_args, "dlm")) {
+			log_error(INTERNAL_ERROR "LV %s/%s has invalid lock_args \"%s\"",
+				   lv->vg->name, display_lvname(lv), lv->lock_args);
+			r = 0;
+		}
+	}
+
+	return r;
+}
+
 int vg_validate(struct volume_group *vg)
 {
 	struct pv_list *pvl;
@@ -2829,6 +2898,9 @@ int vg_validate(struct volume_group *vg)
 				  vg->name, vg->lock_type);
 			r = 0;
 		}
+
+		if (!vg->skip_validate_lock_args && !_validate_vg_lock_args(vg))
+			r = 0;
 	} else {
 		if (vg->lock_args) {
 			log_error(INTERNAL_ERROR "VG %s has lock_args %s without lock_type",
@@ -2840,13 +2912,22 @@ int vg_validate(struct volume_group *vg)
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (is_lockd_type(vg->lock_type)) {
 			if (lockd_lv_uses_lock(lvl->lv)) {
-				if (vg->skip_validate_lock_args) {
+				if (vg->skip_validate_lock_args)
 					continue;
-				} else if (!lvl->lv->lock_args) {
+
+				if (!lvl->lv->lock_args) {
 					log_error(INTERNAL_ERROR "LV %s/%s missing lock_args",
 						  vg->name, lvl->lv->name);
 					r = 0;
-				} else if (!strcmp(vg->lock_type, "sanlock")) {
+					continue;
+				}
+
+				if (!_validate_lv_lock_args(lvl->lv)) {
+					r = 0;
+					continue;
+				}
+
+				if (!strcmp(vg->lock_type, "sanlock")) {
 					if (dm_hash_lookup(vhash.lv_lock_args, lvl->lv->lock_args)) {
 						log_error(INTERNAL_ERROR "LV %s/%s has duplicate lock_args %s.",
 							  vg->name, lvl->lv->name, lvl->lv->lock_args);
@@ -2858,10 +2939,6 @@ int vg_validate(struct volume_group *vg)
 						r = 0;
 					}
 
-				} else if (!strcmp(vg->lock_type, "dlm") && strcmp(lvl->lv->lock_args, "dlm")) {
-					log_error(INTERNAL_ERROR "LV %s/%s bad dlm lock_args %s",
-						  vg->name, lvl->lv->name, lvl->lv->lock_args);
-					r = 0;
 				}
 			} else {
 				if (lvl->lv->lock_args) {


