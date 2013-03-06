From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:36 +0000 (UTC)
Subject: master - config: use config checks and add support for creating trees from config definition (config_def_create_tree fn)
Message-ID: <20130306111536.89402A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=245b85692ec9f30153c1aa7216d81e65bb132792
Commit:        245b85692ec9f30153c1aa7216d81e65bb132792
Parent:        e38aaddb5e72a2123a03dedbb40c2aa594495c17
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 5 17:36:10 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 10:46:35 2013 +0100

config: use config checks and add support for creating trees from config definition (config_def_create_tree fn)

Configuration checking is initiated during config load/processing
(_process_config fn) which is part of the command context
creation/refresh.

This patch also defines 5 types of trees that could be created from
the configuration definition (config_settings.h), the cfg_def_tree_t:

  - CFG_DEF_TREE_CURRENT that denotes a tree of all the configuration
    nodes that are explicitly defined in lvm.conf/--config

  - CFG_DEF_TREE_MISSING that denotes a tree of all missing
    configuration nodes for which default valus are used since they're
    not explicitly used in lvm.conf/--config

  - CFG_DEF_TREE_DEFAULT that denotes a tree of all possible
    configuration nodes with default values assigned, no matter what
    the actual lvm.conf/--config is

  - CFG_DEF_TREE_NEW that denotes a tree of all new configuration nodes
    that appeared in given version

  - CFG_DEF_TREE_COMPLETE that denotes a tree of the whole configuration
    tree that is used in LVM2 (a combination of CFG_DEF_TREE_CURRENT +
    CFG_DEF_TREE_MISSING). This is not implemented yet, it will be added
    later...

The function that creates the definition tree of given type:

  struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec);

Where the "spec" specifies the tree type to be created:

  struct config_def_tree_spec {
    cfg_def_tree_t type;	/* tree type */
    uint16_t version;		/* tree at this LVM2 version */
    int ignoreadvanced;		/* do not include advanced configs */
    int ignoreunsupported;	/* do not include unsupported configs */
  };

This tree can be passed to already existing functions that write
the tree on output (like we already do with cmd->cft).

There is a new lvm.conf section called "config" with two new options:

  - config/checks which enables/disables checking (enabled by default)

  - config/abort_on_errors which enables/disables aborts on any type of
    mismatch found in the config (disabled by default)
---
 doc/example.conf.in          |   15 +++-
 lib/commands/toolcontext.c   |    5 +
 lib/config/config.c          |  235 ++++++++++++++++++++++++++++++++++++++++++
 lib/config/config.h          |   21 ++++-
 lib/config/config_settings.h |    2 +-
 5 files changed, 274 insertions(+), 4 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index ab83c0c..9670b92 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -10,6 +10,20 @@
 # N.B. Take care that each setting only appears once if uncommenting
 # example settings in this file.
 
+# This section allows you to set the way the configuration settings are handled.
+config {
+
+    # If enabled, any LVM2 configuration mismatch is reported.
+    # This implies checking that the configuration key is understood
+    # by LVM2 and that the value of the key is of a proper type.
+    # If disabled, any configuration mismatch is ignored and default
+    # value is used instead without any warning (a message about the
+    # configuration key not being found is issued in verbose mode only).
+    checks = 1
+
+    # If enabled, any configuration mismatch aborts the LVM2 process.
+    abort_on_errors = 0
+}
 
 # This section allows you to configure which block devices should
 # be used by the LVM system.
@@ -359,7 +373,6 @@ shell {
 
 # Miscellaneous global LVM2 settings
 global {
-
     # The file creation mask for any files and directories created.
     # Interpreted as octal if the first digit is zero.
     umask = 077
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1cee204..5dff340 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -290,6 +290,11 @@ static int _process_config(struct cmd_context *cmd)
 	const char *lvmetad_socket;
 	int udev_disabled = 0;
 
+	if (!config_def_check(cmd, 0, 0, 0) && find_config_tree_bool(cmd, config_abort_on_errors_CFG)) {
+		log_error("LVM configuration invalid.");
+		return 0;
+	}
+
 	/* umask */
 	cmd->default_settings.umask = find_config_tree_int(cmd, global_umask_CFG);
 
diff --git a/lib/config/config.c b/lib/config/config.c
index 6f33c12..43f9d21 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -28,6 +28,7 @@
 #include <unistd.h>
 #include <fcntl.h>
 #include <assert.h>
+#include <ctype.h>
 
 struct config_file {
 	time_t timestamp;
@@ -851,3 +852,237 @@ int config_write(struct dm_config_tree *cft, const char *file,
 	return r;
 }
 
+static struct dm_config_value *_get_def_array_values(struct dm_config_tree *cft,
+						     cfg_def_item_t *def)
+{
+	char *enc_value, *token, *p, *r;
+	struct dm_config_value *array = NULL, *v = NULL, *oldv = NULL;
+
+	if (!def->default_value.v_CFG_TYPE_STRING) {
+		if (!(array = dm_config_create_value(cft))) {
+			log_error("Failed to create default empty array for %s.", def->name);
+			return NULL;
+		}
+		array->type = DM_CFG_EMPTY_ARRAY;
+		return array;
+	}
+
+	if (!(p = token = enc_value = dm_strdup(def->default_value.v_CFG_TYPE_STRING))) {
+		log_error("_get_def_array_values: dm_strdup failed");
+		return NULL;
+	}
+	/* Proper value always starts with '#'. */
+	if (token[0] != '#')
+		goto bad;
+
+	while (token) {
+		/* Move to type identifier. Error on no char. */
+		token++;
+		if (!token[0])
+			goto bad;
+
+		/* Move to the actual value and decode any "##" into "#". */
+		p = token + 1;
+		while ((p = strchr(p, '#')) && p[1] == '#') {
+			memmove(p, p + 1, strlen(p));
+			p++;
+		}
+		/* Separate the value out of the whole string. */
+		if (p)
+			p[0] = '\0';
+
+		if (!(v = dm_config_create_value(cft))) {
+			log_error("Failed to create default config array value for %s.", def->name);
+			dm_free(enc_value);
+		}
+		if (oldv)
+			oldv->next = v;
+		if (!array)
+			array = v;
+
+		switch (toupper(token[0])) {
+			case 'I':
+			case 'B':
+				v->v.i = strtoll(token + 1, &r, 10);
+				if (*r)
+					goto bad;
+				v->type = DM_CFG_INT;
+				break;
+			case 'F':
+				v->v.f = strtod(token + 1, &r);
+				if (*r)
+					goto bad;
+				v->type = DM_CFG_FLOAT;
+				break;
+			case 'S':
+				if (!(r = dm_pool_alloc(cft->mem, strlen(token + 1)))) {
+					dm_free(enc_value);
+					log_error("Failed to duplicate token for default "
+						  "array value of %s.", def->name);
+					return NULL;
+				}
+				memcpy(r, token + 1, strlen(token + 1));
+				v->v.str = r;
+				v->type = DM_CFG_STRING;
+				break;
+			default:
+				goto bad;
+		}
+
+		oldv = v;
+		token = p;
+	}
+
+	dm_free(enc_value);
+	return array;
+bad:
+	log_error(INTERNAL_ERROR "Default array value malformed for \"%s\", "
+		  "value: \"%s\", token: \"%s\".", def->name,
+		  def->default_value.v_CFG_TYPE_STRING, token);
+	dm_free(enc_value);
+	return NULL;
+}
+
+static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
+					    struct config_def_tree_spec *spec,
+					    struct dm_config_node *parent,
+					    struct dm_config_node *relay,
+					    cfg_def_item_t *def)
+{
+	struct dm_config_node *cn;
+	const char *str;
+
+	if (!(cn = dm_config_create_node(cft, def->name))) {
+		log_error("Failed to create default config setting node.");
+		return NULL;
+	}
+
+	if (!(def->type & CFG_TYPE_SECTION) && (!(cn->v = dm_config_create_value(cft)))) {
+		log_error("Failed to create default config setting node value.");
+		return NULL;
+	}
+
+	if (!(def->type & CFG_TYPE_ARRAY)) {
+		switch (def->type) {
+			case CFG_TYPE_SECTION:
+				cn->v = NULL;
+				break;
+			case CFG_TYPE_BOOL:
+				cn->v->type = DM_CFG_INT;
+				cn->v->v.i = cfg_def_get_default_value(def, CFG_TYPE_BOOL);
+				break;
+			case CFG_TYPE_INT:
+				cn->v->type = DM_CFG_INT;
+				cn->v->v.i = cfg_def_get_default_value(def, CFG_TYPE_INT);
+				break;
+			case CFG_TYPE_FLOAT:
+				cn->v->type = DM_CFG_FLOAT;
+				cn->v->v.f = cfg_def_get_default_value(def, CFG_TYPE_FLOAT);
+				break;
+			case CFG_TYPE_STRING:
+				cn->v->type = DM_CFG_STRING;
+				if (!(str = cfg_def_get_default_value(def, CFG_TYPE_STRING)))
+					str = "";
+				cn->v->v.str = str;
+				break;
+			default:
+				log_error(INTERNAL_ERROR "_add_def_node: unknown type");
+				return NULL;
+				break;
+		}
+	} else
+		cn->v = _get_def_array_values(cft, def);
+
+	cn->child = NULL;
+	if (parent) {
+		cn->parent = parent;
+		if (!parent->child)
+			parent->child = cn;
+	} else
+		cn->parent = cn;
+
+	if (relay)
+		relay->sib = cn;
+
+	return cn;
+}
+
+static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_id, cfg_def_item_t *def)
+{
+	if (def->parent != section_id)
+		return 1;
+
+	switch (spec->type) {
+		case CFG_DEF_TREE_MISSING:
+			if ((def->flags & CFG_USED) ||
+			    (def->flags & CFG_NAME_VARIABLE) ||
+			    (def->since_version > spec->version))
+				return 1;
+			break;
+		case CFG_DEF_TREE_NEW:
+			if (def->since_version != spec->version)
+				return 1;
+			break;
+		default:
+			if (def->since_version > spec->version)
+				return 1;
+			break;
+	}
+
+	return 0;
+}
+
+static struct dm_config_node *_add_def_section_subtree(struct dm_config_tree *cft,
+						       struct config_def_tree_spec *spec,
+						       struct dm_config_node *parent,
+						       struct dm_config_node *relay,
+						       int section_id)
+{
+	struct dm_config_node *cn = NULL, *relay_sub = NULL, *tmp;
+	cfg_def_item_t *def;
+	int id;
+
+	for (id = 0; id < CFG_COUNT; id++) {
+		def = cfg_def_get_item_p(id);
+		if (_should_skip_def_node(spec, section_id, def))
+			continue;
+
+		if (!cn && !(cn = _add_def_node(cft, spec, parent, relay, cfg_def_get_item_p(section_id))))
+				goto bad;
+
+		if ((tmp = def->type == CFG_TYPE_SECTION ? _add_def_section_subtree(cft, spec, cn, relay_sub, id)
+							 : _add_def_node(cft, spec, cn, relay_sub, def)))
+			relay_sub = tmp;
+	}
+
+	return cn;
+bad:
+	log_error("Failed to create default config section node.");
+	return NULL;
+}
+
+struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec)
+{
+	struct dm_config_tree *cft;
+	struct dm_config_node *root = NULL, *relay = NULL, *tmp;
+	int id;
+
+	if (!(cft = dm_config_create())) {
+		log_error("Failed to create default config tree.");
+		return NULL;
+	}
+
+	for (id = root_CFG_SECTION + 1; id < CFG_COUNT; id++) {
+		if (cfg_def_get_item_p(id)->parent != root_CFG_SECTION)
+			continue;
+
+		if ((tmp = _add_def_section_subtree(cft, spec, root, relay, id))) {
+			relay = tmp;
+			if (!root)
+				root = relay;
+		}
+	}
+
+	cft->root = root;
+	return cft;
+}
diff --git a/lib/config/config.h b/lib/config/config.h
index 624ef59..fb4993a 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -76,6 +76,23 @@ typedef struct cfg_def_item {
 	const char *comment;		/* brief comment */
 } cfg_def_item_t;
 
+/* configuration definition tree types */
+typedef enum {
+	CFG_DEF_TREE_CURRENT,		/* tree of nodes with values currently set in the config */
+	CFG_DEF_TREE_MISSING,		/* tree of nodes missing in current config using default values */
+	CFG_DEF_TREE_COMPLETE,		/* CURRENT + MISSING, the tree actually used within execution, not implemented yet */
+	CFG_DEF_TREE_DEFAULT,		/* tree of all possible config nodes with default values */
+	CFG_DEF_TREE_NEW		/* tree of all new nodes that appeared in given version */
+} cfg_def_tree_t;
+
+/* configuration definition tree specification */
+struct config_def_tree_spec {
+	cfg_def_tree_t type;		/* tree type */
+	uint16_t version;		/* tree at this LVM2 version */
+	int ignoreadvanced;		/* do not include advanced configs */
+	int ignoreunsupported;		/* do not include unsupported configs */
+};
+
 /*
  * Register ID for each possible item in the configuration tree.
  */
@@ -103,8 +120,8 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum);
 int config_file_read(struct dm_config_tree *cft);
-int config_write(struct dm_config_tree *cft, const char *file,
-		 int argc, char **argv);
+int config_write(struct dm_config_tree *cft, const char *file, int argc, char **argv);
+struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec);
 void config_file_destroy(struct dm_config_tree *cft);
 
 time_t config_file_timestamp(struct dm_config_tree *cft);
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index a7d2625..6229f2e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -67,7 +67,7 @@ cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3),
 cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18), NULL)
 
 cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), "Configuration tree check on each LVM command execution.")
-cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2,2,99), "Abort LVM command execution if configuration is invalid.")
+cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99), "Abort LVM command execution if configuration is invalid.")
 
 cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL)
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, 0, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL)


