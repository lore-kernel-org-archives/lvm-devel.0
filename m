From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:17 +0000 (UTC)
Subject: master - toollib: Split --cachesettings from --cachepolicy.
Message-ID: <20141120155317.A335860F50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b9b8e12825d5611d3b8d73aa8e381a4caffff5a
Commit:        4b9b8e12825d5611d3b8d73aa8e381a4caffff5a
Parent:        310beb73a8a2d3a6ed7a28a3346306be82bbc533
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Nov 20 11:30:19 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:07 2014 +0100

toollib: Split --cachesettings from --cachepolicy.

---
 test/shell/lvchange-cache.sh |    7 +++--
 tools/args.h                 |    3 +-
 tools/commands.h             |    4 +-
 tools/lvchange.c             |    3 +-
 tools/toollib.c              |   53 +++++++++++++++++++++--------------------
 5 files changed, 37 insertions(+), 33 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index e790cbb..997b770 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -18,9 +18,10 @@ lvcreate --type cache-pool -an -v -L 2 -n cpool $vg
 lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
 lvcreate -n noncache -l 1 $vg
 
-not lvchange --cachepolicy policy=mq $vg/noncache
+not lvchange --cachepolicy mq $vg/noncache
+not lvchange --cachesettings foo=bar $vg/noncache
 
-lvchange --cachepolicy policy=mq --cachepolicy migration_threshold=333 $vg/corigin
+lvchange --cachepolicy mq --cachesettings migration_threshold=333 $vg/corigin
 dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
 lvchange --refresh $vg/corigin
 dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
@@ -28,7 +29,7 @@ lvchange -an $vg
 lvchange -ay $vg
 dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
 
-lvchange --cachepolicy 'migration_threshold = 233 sequential_threshold = 13' $vg/corigin
+lvchange --cachesettings 'migration_threshold = 233 sequential_threshold = 13' $vg/corigin
 dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
 dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
 
diff --git a/tools/args.h b/tools/args.h
index 63fee14..1abe0eb 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -104,7 +104,8 @@ arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
 arg(type_ARG, '\0', "type", segtype_arg, 0)
 arg(unbuffered_ARG, '\0', "unbuffered", NULL, 0)
 arg(uncache_ARG, '\0', "uncache", NULL, 0)
-arg(cachepolicy_ARG, '\0', "cachepolicy", string_arg, ARG_GROUPABLE)
+arg(cachepolicy_ARG, '\0', "cachepolicy", string_arg, 0)
+arg(cachesettings_ARG, '\0', "cachesettings", string_arg, ARG_GROUPABLE)
 arg(units_ARG, '\0', "units", string_arg, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index e3bac1f..4765923 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -106,7 +106,7 @@ xx(lvchange,
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous y|n]\n"
-   "\t[--cachepolicy policy=type] [--cachepolicy parameter=value]\n"
+   "\t[--cachepolicy policyname] [--cachesettings parameter=value]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[--deltag Tag]\n"
@@ -144,7 +144,7 @@ xx(lvchange,
 
    activationmode_ARG, addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG,
    available_ARG,
-   cachepolicy_ARG, contiguous_ARG, deltag_ARG, discards_ARG, detachprofile_ARG, force_ARG,
+   cachepolicy_ARG, cachesettings_ARG, contiguous_ARG, deltag_ARG, discards_ARG, detachprofile_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, ignoreactivationskip_ARG,
    ignoreskippedcluster_ARG, major_ARG, metadataprofile_ARG, minor_ARG,
    monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, noudevsync_ARG,
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 144295b..d9003b4 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1014,7 +1014,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		docmds++;
 	}
 
-	if (arg_count(cmd, cachepolicy_ARG)) {
+	if (arg_count(cmd, cachepolicy_ARG) || arg_count(cmd, cachesettings_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += lvchange_cachepolicy(cmd, lv);
@@ -1081,6 +1081,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, resync_ARG) ||
 		arg_count(cmd, syncaction_ARG) ||
 		arg_count(cmd, cachepolicy_ARG) ||
+		arg_count(cmd, cachesettings_ARG) ||
 		arg_count(cmd, writebehind_ARG) ||
 		arg_count(cmd, writemostly_ARG) ||
 		arg_count(cmd, zero_ARG);
diff --git a/tools/toollib.c b/tools/toollib.c
index 935f06e..2015ca1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1127,56 +1127,57 @@ struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
 	struct arg_value_group_list *group;
 	struct dm_config_tree *result = NULL, *prev = NULL, *current = NULL;
 	struct dm_config_node *cn, *last = NULL;
+	int ok = 0;
 
 	dm_list_iterate_items(group, &cmd->arg_value_groups) {
-		if (!grouped_arg_is_set(group->arg_values, cachepolicy_ARG))
+		if (!grouped_arg_is_set(group->arg_values, cachesettings_ARG))
 			continue;
 
 		current = dm_config_create();
 		if (!current)
-			goto_bad;
+			goto_out;
 		if (prev)
 			current->cascade = prev;
 		prev = current;
 
 		if (!(str = grouped_arg_str_value(group->arg_values,
-						  cachepolicy_ARG,
+						  cachesettings_ARG,
 						  NULL)))
-			goto_bad;
+			goto_out;
 
 		if (!dm_config_parse(current, str, str + strlen(str)))
-			goto_bad;
+			goto_out;
 	}
 
 	result = dm_config_flatten(current);
-	if (!(cn = dm_config_create_node(result, "policy_settings"))) {
-		dm_config_destroy(result);
-		result = NULL;
-	}
+
+	if (!(cn = dm_config_create_node(result, "policy_settings")))
+		goto_out;
+
 	cn->child = result->root;
 	result->root = cn;
-	cn = cn->child;
 
-	while (cn) {
-		if (!strcmp(cn->key, "policy")) {
-			if (last)
-				last->sib = cn->sib;
-			else
-				result->root->child = cn->sib;
-			cn->parent = NULL;
-			cn->sib = NULL;
-			result->root->sib = cn;
-		}
-		last = cn;
-		cn = cn->sib;
+	if (arg_count(cmd, cachepolicy_ARG)) {
+		if (!(cn = dm_config_create_node(result, "policy")))
+			goto_out;
+
+		result->root->sib = cn;
+		if (!(cn->v = dm_config_create_value(result)))
+			goto_out;
+
+		cn->v->v.str = arg_str_value(cmd, cachepolicy_ARG, NULL);
 	}
 
-	if (!_validate_cachepool_params(current)) {
+	if (!_validate_cachepool_params(result))
+		goto_out;
+
+	ok = 1;
+
+out:
+	if (!ok) {
 		dm_config_destroy(result);
 		result = NULL;
 	}
-
-bad:
 	while (prev) {
 		current = prev->cascade;
 		dm_config_destroy(prev);


