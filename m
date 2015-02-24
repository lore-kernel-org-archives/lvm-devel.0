From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 24 Feb 2015 10:39:05 +0000 (UTC)
Subject: master - cache: Fix a segfault when passing --cachepolicy without --cachesettings.
Message-ID: <20150224103905.955C3610DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d615a3fe58e76af4d3b192298d55a60de9b0d5d
Commit:        7d615a3fe58e76af4d3b192298d55a60de9b0d5d
Parent:        5793ecd16541961ebb91239395dc82504ad31906
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Tue Feb 24 11:36:30 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Tue Feb 24 11:39:35 2015 +0100

cache: Fix a segfault when passing --cachepolicy without --cachesettings.

---
 WHATS_NEW                    |    1 +
 lib/metadata/cache_manip.c   |    5 +++--
 test/shell/lvchange-cache.sh |    5 +++++
 tools/toollib.c              |   13 ++++++++-----
 4 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6220398..8e80241 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Do not crash when --cachepolicy is given without --cachesettings.
   Add NEEDS_FOREIGN_VGS flag to vgimport so --foreign is always supplied.
   Add --foreign to the 6 display and reporting tools and vgcfgbackup.
   Install /etc/lvm/lvmlocal.conf template with local section for systemid.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 6a13ec1..41de440 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -418,7 +418,8 @@ int lv_cache_setpolicy(struct logical_volume *lv, struct dm_config_tree *policy)
 			goto_out;
 	}
 
-	if (!(seg->policy_settings = dm_config_clone_node_with_mem(lv->vg->vgmem, policy->root, 0)))
+	if ((cn = dm_config_find_node(policy->root, "policy_settings")) &&
+	    !(seg->policy_settings = dm_config_clone_node_with_mem(lv->vg->vgmem, cn, 0)))
 		goto_out;
 
 	if ((name = dm_config_find_str(policy->root, "policy", NULL)) &&
@@ -426,7 +427,7 @@ int lv_cache_setpolicy(struct logical_volume *lv, struct dm_config_tree *policy)
 		goto_out;
 
 restart: /* remove any 'default" nodes */
-	cn = seg->policy_settings->child;
+	cn = seg->policy_settings ? seg->policy_settings->child : NULL;
 	while (cn) {
 		if (cn->v->type == DM_CFG_STRING && !strcmp(cn->v->v.str, "default")) {
 			dm_config_remove_node(seg->policy_settings, cn);
diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 87a217a..9959f93 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -21,7 +21,12 @@ lvcreate -n noncache -l 1 $vg
 not lvchange --cachepolicy mq $vg/noncache
 not lvchange --cachesettings foo=bar $vg/noncache
 
+lvchange --cachepolicy cleaner $vg/corigin
+dmsetup status | grep $vg-corigin | grep 'cleaner'
+
 lvchange --cachepolicy mq --cachesettings migration_threshold=333 $vg/corigin
+dmsetup status | grep $vg-corigin | not grep 'cleaner'
+dmsetup status | grep $vg-corigin | grep 'mq'
 dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
 lvchange --refresh $vg/corigin
 dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
diff --git a/tools/toollib.c b/tools/toollib.c
index b1795e7..b8b0bad 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1232,17 +1232,20 @@ struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
 	if (!(result = dm_config_flatten(current)))
 		goto_out;
 
-	if (!(cn = dm_config_create_node(result, "policy_settings")))
-		goto_out;
+	if (result->root) {
+		if (!(cn = dm_config_create_node(result, "policy_settings")))
+			goto_out;
 
-	cn->child = result->root;
-	result->root = cn;
+		cn->child = result->root;
+		result->root = cn;
+	}
 
 	if (arg_count(cmd, cachepolicy_ARG)) {
 		if (!(cn = dm_config_create_node(result, "policy")))
 			goto_out;
 
-		result->root->sib = cn;
+		cn->sib = result->root;
+		result->root = cn;
 		if (!(cn->v = dm_config_create_value(result)))
 			goto_out;
 


