From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:11 +0000 (UTC)
Subject: master - toollib: Add --cachepolicy and implement get_cachepolicy_params.
Message-ID: <20141120155311.63B5E60DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f67e1fadb0fcdc5887663f9b0c9c46fc5835d418
Commit:        f67e1fadb0fcdc5887663f9b0c9c46fc5835d418
Parent:        d22ffd8c289f570b3406f684212b6e7821179710
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Nov 19 18:39:29 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:06 2014 +0100

toollib: Add --cachepolicy and implement get_cachepolicy_params.

---
 tools/args.h    |    1 +
 tools/toollib.c |   69 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/toollib.h |    2 +
 3 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 000af01..63fee14 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -104,6 +104,7 @@ arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
 arg(type_ARG, '\0', "type", segtype_arg, 0)
 arg(unbuffered_ARG, '\0', "unbuffered", NULL, 0)
 arg(uncache_ARG, '\0', "uncache", NULL, 0)
+arg(cachepolicy_ARG, '\0', "cachepolicy", string_arg, ARG_GROUPABLE)
 arg(units_ARG, '\0', "units", string_arg, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
diff --git a/tools/toollib.c b/tools/toollib.c
index d33de79..935f06e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1116,6 +1116,75 @@ int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stri
 	return _validate_stripe_params(cmd, stripes, stripe_size);
 }
 
+static int _validate_cachepool_params(struct dm_config_tree *tree)
+{
+	return 1;
+}
+
+struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
+{
+	const char *str;
+	struct arg_value_group_list *group;
+	struct dm_config_tree *result = NULL, *prev = NULL, *current = NULL;
+	struct dm_config_node *cn, *last = NULL;
+
+	dm_list_iterate_items(group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(group->arg_values, cachepolicy_ARG))
+			continue;
+
+		current = dm_config_create();
+		if (!current)
+			goto_bad;
+		if (prev)
+			current->cascade = prev;
+		prev = current;
+
+		if (!(str = grouped_arg_str_value(group->arg_values,
+						  cachepolicy_ARG,
+						  NULL)))
+			goto_bad;
+
+		if (!dm_config_parse(current, str, str + strlen(str)))
+			goto_bad;
+	}
+
+	result = dm_config_flatten(current);
+	if (!(cn = dm_config_create_node(result, "policy_settings"))) {
+		dm_config_destroy(result);
+		result = NULL;
+	}
+	cn->child = result->root;
+	result->root = cn;
+	cn = cn->child;
+
+	while (cn) {
+		if (!strcmp(cn->key, "policy")) {
+			if (last)
+				last->sib = cn->sib;
+			else
+				result->root->child = cn->sib;
+			cn->parent = NULL;
+			cn->sib = NULL;
+			result->root->sib = cn;
+		}
+		last = cn;
+		cn = cn->sib;
+	}
+
+	if (!_validate_cachepool_params(current)) {
+		dm_config_destroy(result);
+		result = NULL;
+	}
+
+bad:
+	while (prev) {
+		current = prev->cascade;
+		dm_config_destroy(prev);
+		prev = current;
+	}
+	return result;
+}
+
 /* FIXME move to lib */
 static int _pv_change_tag(struct physical_volume *pv, const char *tag, int addtag)
 {
diff --git a/tools/toollib.h b/tools/toollib.h
index 9040387..715f65e 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -123,6 +123,8 @@ int get_pool_params(struct cmd_context *cmd,
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 
+struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd);
+
 int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	       struct logical_volume *lv, struct physical_volume *pv, int arg);
 


