From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  8 Jul 2013 14:06:29 +0000 (UTC)
Subject: master - config: make it possible to do a raw config tree merge
Message-ID: <20130708140629.A624A6073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1e289001286f978630f5e6423acca1af322ebd7
Commit:        f1e289001286f978630f5e6423acca1af322ebd7
Parent:        661406a417e3cbf2170ba7c3debd767d50e99cae
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 8 14:31:44 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 8 15:59:25 2013 +0200

config: make it possible to do a raw config tree merge

Till now, we needed the config tree merge only for merging
tag configs with lvm.conf. However, this type of merging
did a few extra exceptions:

  - leaving out the tags section
  - merging values in activation/volume_list
  - merging values in devices/filter
  - merging values in devices/types

Any other config values were replaced by new values.
However, we'd like to do a 'raw merge' as well, simply
bypassing the exceptions listed above. This will help
us to create a single tree representing the cascaded
configs like CONFIG_STRING -> CONFIG_PROFILE -> ...

The reason for this patch is that when trees are cascaded,
the first value found while traversing the cascade is used,
not making any exceptions like we do for tag configs.
---
 lib/commands/toolcontext.c |    2 +-
 lib/config/config.c        |   69 +++++++++++++++++++++++++-------------------
 lib/config/config.h        |   13 +++++++-
 3 files changed, 52 insertions(+), 32 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4919b93..2c4a698 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -659,7 +659,7 @@ static struct dm_config_tree *_merge_config_files(struct cmd_context *cmd, struc
 
 	dm_list_iterate_items(cfl, &cmd->config_files) {
 		/* Merge all config trees into cmd->cft using merge/tag rules */
-		if (!merge_config_tree(cmd, cft, cfl->cft))
+		if (!merge_config_tree(cmd, cft, cfl->cft, CONFIG_MERGE_TYPE_TAGS))
 			return_0;
 	}
 
diff --git a/lib/config/config.c b/lib/config/config.c
index 26b2aa8..4c1b415 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -955,7 +955,8 @@ static void _insert_config_node(struct dm_config_node **cn1,
  * Merge section cn2 into section cn1 (which has the same name)
  * overwriting any existing cn1 nodes with matching names.
  */
-static void _merge_section(struct dm_config_node *cn1, struct dm_config_node *cn2)
+static void _merge_section(struct dm_config_node *cn1, struct dm_config_node *cn2,
+			   config_merge_t merge_type)
 {
 	struct dm_config_node *cn, *nextn, *oldn;
 	struct dm_config_value *cv;
@@ -963,9 +964,11 @@ static void _merge_section(struct dm_config_node *cn1, struct dm_config_node *cn
 	for (cn = cn2->child; cn; cn = nextn) {
 		nextn = cn->sib;
 
-		/* Skip "tags" */
-		if (!strcmp(cn->key, "tags"))
-			continue;
+		if (merge_type == CONFIG_MERGE_TYPE_TAGS) {
+			/* Skip "tags" */
+			if (!strcmp(cn->key, "tags"))
+				continue;
+		}
 
 		/* Subsection? */
 		if (!cn->v)
@@ -976,15 +979,17 @@ static void _merge_section(struct dm_config_node *cn1, struct dm_config_node *cn
 			_insert_config_node(&cn1->child, cn);
 			continue;
 		}
-		/* Merge certain value lists */
-		if ((!strcmp(cn1->key, "activation") &&
-		     !strcmp(cn->key, "volume_list")) ||
-		    (!strcmp(cn1->key, "devices") &&
-		     (!strcmp(cn->key, "filter") || !strcmp(cn->key, "types")))) {
-			cv = cn->v;
-			while (cv->next)
-				cv = cv->next;
-			cv->next = oldn->v;
+		if (merge_type == CONFIG_MERGE_TYPE_TAGS) {
+			/* Merge certain value lists */
+			if ((!strcmp(cn1->key, "activation") &&
+			     !strcmp(cn->key, "volume_list")) ||
+			    (!strcmp(cn1->key, "devices") &&
+			     (!strcmp(cn->key, "filter") || !strcmp(cn->key, "types")))) {
+				cv = cn->v;
+				while (cv->next)
+					cv = cv->next;
+				cv->next = oldn->v;
+			}
 		}
 
 		/* Replace values */
@@ -1014,7 +1019,7 @@ static int _match_host_tags(struct dm_list *tags, const struct dm_config_node *t
 
 /* Destructively merge a new config tree into an existing one */
 int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
-		      struct dm_config_tree *newdata)
+		      struct dm_config_tree *newdata, config_merge_t merge_type)
 {
 	struct dm_config_node *root = cft->root;
 	struct dm_config_node *cn, *nextn, *oldn, *cn2;
@@ -1023,30 +1028,34 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 
 	for (cn = newdata->root; cn; cn = nextn) {
 		nextn = cn->sib;
-		/* Ignore tags section */
-		if (!strcmp(cn->key, "tags"))
-			continue;
-		/* If there's a tags node, skip if host tags don't match */
-		if ((tn = dm_config_find_node(cn->child, "tags"))) {
-			if (!_match_host_tags(&cmd->tags, tn))
+		if (merge_type == CONFIG_MERGE_TYPE_TAGS) {
+			/* Ignore tags section */
+			if (!strcmp(cn->key, "tags"))
 				continue;
+			/* If there's a tags node, skip if host tags don't match */
+			if ((tn = dm_config_find_node(cn->child, "tags"))) {
+				if (!_match_host_tags(&cmd->tags, tn))
+					continue;
+			}
 		}
 		if (!(oldn = dm_config_find_node(root, cn->key))) {
 			_insert_config_node(&cft->root, cn);
-			/* Remove any "tags" nodes */
-			for (cn2 = cn->child; cn2; cn2 = cn2->sib) {
-				if (!strcmp(cn2->key, "tags")) {
-					cn->child = cn2->sib;
-					continue;
-				}
-				if (cn2->sib && !strcmp(cn2->sib->key, "tags")) {
-					cn2->sib = cn2->sib->sib;
-					continue;
+			if (merge_type == CONFIG_MERGE_TYPE_TAGS) {
+				/* Remove any "tags" nodes */
+				for (cn2 = cn->child; cn2; cn2 = cn2->sib) {
+					if (!strcmp(cn2->key, "tags")) {
+						cn->child = cn2->sib;
+						continue;
+					}
+					if (cn2->sib && !strcmp(cn2->sib->key, "tags")) {
+						cn2->sib = cn2->sib->sib;
+						continue;
+					}
 				}
 			}
 			continue;
 		}
-		_merge_section(oldn, cn);
+		_merge_section(oldn, cn, merge_type);
 	}
 
 	/*
diff --git a/lib/config/config.h b/lib/config/config.h
index 9f54af6..94fd1d9 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -173,8 +173,19 @@ int config_file_changed(struct dm_config_tree *cft);
 int config_file_check(struct dm_config_tree *cft, const char **filename, struct stat *info);
 
 
+typedef enum {
+	CONFIG_MERGE_TYPE_RAW,	/* always replace old config values with new config values when merging */
+	CONFIG_MERGE_TYPE_TAGS	/* apply some exceptions when merging tag configs:
+				     - skip tags section
+				     - do not replace, but merge values of these settings:
+					activation/volume_list
+					devices/filter
+					devices/types
+				 */
+} config_merge_t;
+
 int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
-		      struct dm_config_tree *newdata);
+		      struct dm_config_tree *newdata, config_merge_t);
 
 /*
  * These versions check an override tree, if present, first.


