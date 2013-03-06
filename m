From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:33 +0000 (UTC)
Subject: master - config: add support for configuration check (config_def_check fn)
Message-ID: <20130306111533.D8CC1A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e38aaddb5e72a2123a03dedbb40c2aa594495c17
Commit:        e38aaddb5e72a2123a03dedbb40c2aa594495c17
Parent:        296385c0f3fa5176704c42f92210e7c5d38996ad
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 5 17:14:18 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 10:17:18 2013 +0100

config: add support for configuration check (config_def_check fn)

Add support for configuration checking - type checking and recognition
of registered configuration settings that LVM2 understands and also
check the structure of the configuration. Log error on any mismatch
found.

A hash over all allowed configuration paths is created which helps
with matching the exact configuration (lvm.conf/--config tree) with
the configuration item definition from config_settings.h in an
efficient and one-step way.

Two more helper flags are introduced for each configuration definition
item:

  - CFG_USED which marks the item as being used (lvm.conf/--config)
    This helps with identifying missing configuration options
    (and for which defaults were used) when traversing the tree later.

  - CFG_VALID which denotes that the item has already been checked and
    it was found valid. This improves performance, so if the check
    is called once again on the same tree which was not reloaded, we
    can just return the state from previous check (with a possibility
    to force the check if needed).

The new function that config.h exports and which is going to be used
to perform the configuration checking is:

  int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_messages)

...which is exported internally via config.h.
---
 lib/config/config.c |  283 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/config/config.h |    5 +
 2 files changed, 288 insertions(+), 0 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 8234cf4..6f33c12 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -334,6 +334,289 @@ int config_def_get_path(char *buf, size_t buf_size, int id)
 	return _cfg_def_make_path(buf, buf_size, id, cfg_def_get_item_p(id));
 }
 
+static void _get_type_name(char *buf, size_t buf_size, cfg_def_type_t type)
+{
+	buf[0] = '\0';
+
+	if (type & CFG_TYPE_ARRAY) {
+		if (type & ~CFG_TYPE_ARRAY)
+			strncat(buf, " array with values of type:", buf_size);
+		else {
+			strncat(buf, " array", buf_size);
+			return;
+		}
+	}
+
+	if (type & CFG_TYPE_SECTION)
+		strncat(buf, " section", buf_size);
+	if (type & CFG_TYPE_BOOL)
+		strncat(buf, " boolean", buf_size);
+	if (type & CFG_TYPE_INT)
+		strncat(buf, " integer", buf_size);
+	if (type & CFG_TYPE_FLOAT)
+		strncat(buf, " float", buf_size);
+	if (type & CFG_TYPE_STRING)
+		strncat(buf, " string", buf_size);
+}
+
+static void _log_type_error(const char *path, cfg_def_type_t actual,
+			    cfg_def_type_t expected, int suppress_messages)
+{
+	static char actual_type_name[64];
+	static char expected_type_name[64];
+
+	_get_type_name(actual_type_name, sizeof(actual_type_name), actual);
+	_get_type_name(expected_type_name, sizeof(expected_type_name), expected);
+
+	log_warn_suppress(suppress_messages, "Configuration setting \"%s\" has invalid type. "
+					     "Found%s, expected%s.", path,
+					     actual_type_name, expected_type_name);
+}
+
+static int _config_def_check_node_single_value(const char *rp, const struct dm_config_value *v,
+					       const cfg_def_item_t *def, int suppress_messages)
+{
+	/* Check empty array first if present. */
+	if (v->type == DM_CFG_EMPTY_ARRAY) {
+		if (!(def->type & CFG_TYPE_ARRAY)) {
+			_log_type_error(rp, CFG_TYPE_ARRAY, def->type, suppress_messages);
+			return 0;
+		}
+		if (!(def->flags & CFG_ALLOW_EMPTY)) {
+			log_warn_suppress(suppress_messages,
+				"Configuration setting \"%s\" invalid. Empty value not allowed.", rp);
+			return 0;
+		}
+		return 1;
+	}
+
+	switch (v->type) {
+		case DM_CFG_INT:
+			if (!(def->type & CFG_TYPE_INT) && !(def->type & CFG_TYPE_BOOL)) {
+				_log_type_error(rp, CFG_TYPE_INT, def->type, suppress_messages);
+				return 0;
+			}
+			break;
+		case DM_CFG_FLOAT:
+			if (!(def->type & CFG_TYPE_FLOAT)) {
+				_log_type_error(rp, CFG_TYPE_FLOAT, def->type, suppress_messages);
+				return 0;
+			}
+			break;
+		case DM_CFG_STRING:
+			if (def->type & CFG_TYPE_BOOL) {
+				if (!dm_config_value_is_bool(v)) {
+					log_warn_suppress(suppress_messages,
+						"Configuration setting \"%s\" invalid. "
+						"Found string value \"%s\", "
+						"expected boolean value: 0/1, \"y/n\", "
+						"\"yes/no\", \"on/off\", "
+						"\"true/false\".", rp, v->v.str);
+					return 0;
+				}
+			} else if  (!(def->type & CFG_TYPE_STRING)) {
+				_log_type_error(rp, CFG_TYPE_STRING, def->type, suppress_messages);
+				return 0;
+			}
+			break;
+		default: ;
+	}
+
+	return 1;
+}
+
+static int _config_def_check_node_value(const char *rp, const struct dm_config_value *v,
+					const cfg_def_item_t *def, int suppress_messages)
+{
+	if (!v) {
+		if (def->type != CFG_TYPE_SECTION) {
+			_log_type_error(rp, CFG_TYPE_SECTION, def->type, suppress_messages);
+			return 0;
+		}
+		return 1;
+	}
+
+	if (v->next) {
+		if (!(def->type & CFG_TYPE_ARRAY)) {
+			_log_type_error(rp, CFG_TYPE_ARRAY, def->type, suppress_messages);
+			return 0;
+		}
+	}
+
+	do {
+		if (!_config_def_check_node_single_value(rp, v, def, suppress_messages))
+			return 0;
+		v = v->next;
+	} while (v);
+
+	return 1;
+}
+
+static int _config_def_check_node(const char *vp, char *pvp, char *rp, char *prp,
+				  size_t buf_size, struct dm_config_node *cn,
+				  struct dm_hash_table *ht, int suppress_messages)
+{
+	cfg_def_item_t *def;
+	int sep = vp != pvp; /* don't use '/' separator for top-level node */
+
+	if (dm_snprintf(pvp, buf_size, "%s%s", sep ? "/" : "", cn->key) < 0 ||
+	    dm_snprintf(prp, buf_size, "%s%s", sep ? "/" : "", cn->key) < 0) {
+		log_error("Failed to construct path for configuration node %s.", cn->key);
+		return 0;
+	}
+
+
+	if (!(def = (cfg_def_item_t *) dm_hash_lookup(ht, vp))) {
+		/* If the node is not a section but a setting, fail now. */
+		if (cn->v) {
+			log_warn_suppress(suppress_messages,
+				"Configuration setting \"%s\" unknown.", rp);
+			return 0;
+		}
+
+		/* If the node is a section, try if the section name is variable. */
+		/* Modify virtual path vp in situ and replace the key name with a '#'. */
+		/* The real path without '#' is still stored in rp variable. */
+		pvp[sep] = '#', pvp[sep + 1] = '\0';
+		if (!(def = (cfg_def_item_t *) dm_hash_lookup(ht, vp))) {
+			log_warn_suppress(suppress_messages,
+				"Configuration section \"%s\" unknown.", rp);
+			return 0;
+		}
+	}
+
+	def->flags |= CFG_USED;
+	if (!_config_def_check_node_value(rp, cn->v, def, suppress_messages))
+		return 0;
+
+	def->flags |= CFG_VALID;
+	return 1;
+}
+
+static int _config_def_check_tree(const char *vp, char *pvp, char *rp, char *prp,
+				  size_t buf_size, struct dm_config_node *root,
+				  struct dm_hash_table *ht, int suppress_messages)
+{
+	struct dm_config_node *cn;
+	int valid, r = 1;
+	size_t len;
+
+	for (cn = root->child; cn; cn = cn->sib) {
+		if ((valid = _config_def_check_node(vp, pvp, rp, prp, buf_size,
+					cn, ht, suppress_messages)) && !cn->v) {
+			len = strlen(rp);
+			valid = _config_def_check_tree(vp, pvp + strlen(pvp),
+					rp, prp + len, buf_size - len, cn, ht,
+					suppress_messages);
+		}
+		if (!valid)
+			r = 0;
+	}
+
+	return r;
+}
+
+int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_messages)
+{
+	cfg_def_item_t *def;
+	struct dm_config_node *cn;
+	char *vp = _cfg_path, rp[CFG_PATH_MAX_LEN];
+	size_t rplen;
+	int id, r = 1;
+
+	/*
+	 * vp = virtual path, it might contain substitutes for variable parts
+	 * 	of the path, used while working with the hash
+	 * rp = real path, the real path of the config element as found in the
+	 *      configuration, used for message output
+	 */
+
+	/*
+	 * If the check has already been done and 'skip' is set,
+	 * skip the actual check and use last result if available.
+	 * If not available, we must do the check. The global status
+	 * is stored in root node.
+	 */
+	def = cfg_def_get_item_p(root_CFG_SECTION);
+	if (skip && (def->flags & CFG_USED))
+		return def->flags & CFG_VALID;
+
+	/* Clear 'used' and 'valid' status flags. */
+	for (id = 0; id < CFG_COUNT; id++) {
+		def = cfg_def_get_item_p(id);
+		def->flags &= ~(CFG_USED | CFG_VALID);
+	}
+
+	if (!force && !find_config_tree_bool(cmd, config_checks_CFG)) {
+		if (cmd->cft_def_hash) {
+			dm_hash_destroy(cmd->cft_def_hash);
+			cmd->cft_def_hash = NULL;
+		}
+		return 1;
+	}
+
+	/*
+	 * Create a hash of all possible configuration
+	 * sections and settings with full path as a key.
+	 * If section name is variable, use '#' as a substitute.
+	 */
+	if (!cmd->cft_def_hash) {
+		if (!(cmd->cft_def_hash = dm_hash_create(64))) {
+			log_error("Failed to create configuration definition hash.");
+			r = 0; goto out;
+		}
+		for (id = 1; id < CFG_COUNT; id++) {
+			def = cfg_def_get_item_p(id);
+			if (!cfg_def_get_path(def)) {
+				dm_hash_destroy(cmd->cft_def_hash);
+				cmd->cft_def_hash = NULL;
+				r = 0; goto out;
+			}
+			dm_hash_insert(cmd->cft_def_hash, dm_strdup(vp), def);
+		}
+	}
+
+	cfg_def_get_item_p(root_CFG_SECTION)->flags |= CFG_USED;
+
+	/*
+	 * Allow only sections as top-level elements.
+	 * Iterate top-level sections and dive deeper.
+	 * If any of subsequent checks fails, the whole check fails.
+	 */
+	for (cn = cmd->cft->root; cn; cn = cn->sib) {
+		if (!cn->v) {
+			/* top level node: vp=vp, rp=rp */
+			if (!_config_def_check_node(vp, vp, rp, rp,
+						    CFG_PATH_MAX_LEN,
+						    cn, cmd->cft_def_hash,
+						    suppress_messages)) {
+				r = 0; continue;
+			}
+			rplen = strlen(rp);
+			if (!_config_def_check_tree(vp, vp + strlen(vp),
+						    rp, rp + rplen,
+						    CFG_PATH_MAX_LEN - rplen,
+						    cn, cmd->cft_def_hash,
+						    suppress_messages))
+				r = 0;
+		} else {
+			log_error_suppress(suppress_messages,
+				"Configuration setting \"%s\" invalid. "
+				"It's not part of any section.", cn->key);
+			r = 0;
+		}
+	}
+out:
+	if (r) {
+		cfg_def_get_item_p(root_CFG_SECTION)->flags |= CFG_VALID;
+		def->flags |= CFG_VALID;
+	} else {
+		cfg_def_get_item_p(root_CFG_SECTION)->flags &= ~CFG_VALID;
+		def->flags &= ~CFG_VALID;
+	}
+	return r;
+}
+
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id)
 {
 	return dm_config_tree_find_node(cmd->cft, cfg_def_get_path(cfg_def_get_item_p(id)));
diff --git a/lib/config/config.h b/lib/config/config.h
index a239e1d..624ef59 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -59,6 +59,10 @@ typedef union {
 #define CFG_ADVANCED		0x04
 /* whether the configuraton item is not officially supported */
 #define CFG_UNSUPPORTED		0x08
+/* helper flag to mark the item as used in a config tree instance */
+#define CFG_USED		0x10
+/* helper flag to mark the item as valid in a config tree instance */
+#define CFG_VALID		0x20
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
@@ -86,6 +90,7 @@ enum {
 };
 
 int config_def_get_path(char *buf, size_t buf_size, int id);
+int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_messages);
 
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings);


