From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:43 +0000 (UTC)
Subject: master - thin: for thin volumes properly list modules
Message-ID: <20130718162643.B732160DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e724f5f52e3f641d1ccc5a90d0af2ad73a52a8d
Commit:        4e724f5f52e3f641d1ccc5a90d0af2ad73a52a8d
Parent:        d72f34af418b90c71e8e96f408d4953e679e0895
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 18 16:06:26 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:43 2013 +0200

thin: for thin volumes properly list modules

thin volume needs   thin-pool and  thin kernel modules so print them
both for   lvs -o+modules
---
 WHATS_NEW                   |    1 +
 lib/thin/thin.c             |   38 ++++++++++++++++++++++++++++----------
 test/shell/lvcreate-thin.sh |    2 +-
 3 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7b2c2d0..f49c71c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  List thin-pool and thin modules for thin volumes.
   Correct thin creation error paths.
   Use local activation for clearing snapshot COW device.
   Add lvm2-activation-net systemd unit to activate LVs on net-attached storage.
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 9bc9e4d..520a3d2 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -27,7 +27,8 @@
 #endif
 
 /* Dm kernel module name for thin provisiong */
-#define THIN_MODULE "thin-pool"
+static const char _thin_pool_module[] = "thin-pool";
+static const char _thin_module[] = "thin";
 
 /*
  * Macro used as return argument - returns 0.
@@ -376,6 +377,18 @@ static int _thin_pool_target_percent(void **target_state __attribute__((unused))
 	return 1;
 }
 
+static int _thin_pool_modules_needed(struct dm_pool *mem,
+				     const struct lv_segment *seg __attribute__((unused)),
+				     struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, _thin_pool_module)) {
+		log_error("String list allocation failed for thin_pool.");
+		return 0;
+	}
+
+	return 1;
+}
+
 #  ifdef DMEVENTD
 static const char *_get_thin_dso_path(struct cmd_context *cmd)
 {
@@ -581,10 +594,10 @@ static int _thin_target_present(struct cmd_context *cmd,
 	const char *str;
 
 	if (!_checked) {
-		_present = target_present(cmd, THIN_MODULE, 1);
+		_present = target_present(cmd, _thin_pool_module, 1);
 
-		if (!target_version(THIN_MODULE, &maj, &min, &patchlevel)) {
-			log_error("Cannot read " THIN_MODULE " target version.");
+		if (!target_version(_thin_pool_module, &maj, &min, &patchlevel)) {
+			log_error("Cannot read %s target version.", _thin_pool_module);
 			return 0;
 		}
 
@@ -592,7 +605,8 @@ static int _thin_target_present(struct cmd_context *cmd,
 			if (maj >= _features[i].maj && min >= _features[i].min)
 				_attrs |= _features[i].thin_feature;
 			else
-				log_very_verbose("Target " THIN_MODULE " does not support %s.",
+				log_very_verbose("Target %s does not support %s.",
+						 _thin_pool_module,
 						 _features[i].feature);
 
 		_checked = 1;
@@ -623,7 +637,8 @@ static int _thin_target_present(struct cmd_context *cmd,
 			for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
 				if ((_attrs & _features[i].thin_feature) &&
 				    !(_feature_mask & _features[i].thin_feature))
-					log_very_verbose("Target "THIN_MODULE " %s support disabled by %s",
+					log_very_verbose("Target %s %s support disabled by %s",
+							 _thin_pool_module,
 							 _features[i].feature, _lvmconf);
 		}
 		*attributes = _attrs & _feature_mask;
@@ -634,11 +649,14 @@ static int _thin_target_present(struct cmd_context *cmd,
 #endif
 
 static int _thin_modules_needed(struct dm_pool *mem,
-				const struct lv_segment *seg __attribute__((unused)),
+				const struct lv_segment *seg,
 				struct dm_list *modules)
 {
-	if (!str_list_add(mem, modules, THIN_MODULE)) {
-		log_error("thin string list allocation failed");
+	if (!_thin_pool_modules_needed(mem, seg, modules))
+		return_0;
+
+	if (!str_list_add(mem, modules, _thin_module)) {
+		log_error("String list allocation failed for thin.");
 		return 0;
 	}
 
@@ -665,7 +683,7 @@ static struct segtype_handler _thin_pool_ops = {
 	.target_unmonitor_events = _target_unregister_events,
 #  endif /* DMEVENTD */
 #endif
-	.modules_needed = _thin_modules_needed,
+	.modules_needed = _thin_pool_modules_needed,
 	.destroy = _thin_destroy,
 };
 
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 275c56f..2ae02ab 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -144,7 +144,7 @@ lvcreate --type snapshot $vg/lv1 --name lv6
 lvcreate --type snapshot $vg/lv1 --name lv4
 lvcreate --type snapshot $vg/lv1 --name $vg/lv5
 
-check_lv_field_modules_ thin-pool lv1 snap_lv1 lv2 lv3 lv4 lv5 lv6
+check_lv_field_modules_ thin-pool,thin lv1 snap_lv1 lv2 lv3 lv4 lv5 lv6
 check vg_field $vg lv_count 8
 lvremove -ff $vg
 


