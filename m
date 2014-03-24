From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 24 Mar 2014 14:36:27 +0000 (UTC)
Subject: master - config: add support for comparing used config values with default ones
Message-ID: <20140324143627.9472B60DA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76ff38fa5cdec332750452c2ed209d4beac261eb
Commit:        76ff38fa5cdec332750452c2ed209d4beac261eb
Parent:        630e0af14e65a860ee941adb2422628bec5ec95c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 21 10:43:44 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 24 15:35:47 2014 +0100

config: add support for comparing used config values with default ones

---
 lib/config/config.c |   88 ++++++++++++++++++++++++++++++++++++++++++++++++--
 lib/config/config.h |    3 ++
 2 files changed, 87 insertions(+), 4 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 425d3c6..46e0cc1 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -30,6 +30,8 @@
 #include <fcntl.h>
 #include <assert.h>
 #include <ctype.h>
+#include <math.h>
+#include <float.h>
 
 static const char *_config_source_names[] = {
 	[CONFIG_UNDEFINED] = "undefined",
@@ -681,10 +683,84 @@ static int _config_def_check_node_single_value(struct cft_check_handle *handle,
 	return 1;
 }
 
+static int _check_value_differs_from_default(struct cft_check_handle *handle,
+					     const struct dm_config_value *v,
+					     const cfg_def_item_t *def,
+					     struct dm_config_value *v_def)
+{
+	struct dm_config_value *v_def_array, *v_def_iter;
+	int diff = 0, id;
+	int64_t i;
+	float f;
+	const char *str;
+
+	/* if default value is undefined, the value used differs from default */
+	if (def->flags & CFG_DEFAULT_UNDEFINED) {
+		diff = 1;
+		goto out;
+	}
+
+	if (!v_def && (def->type & CFG_TYPE_ARRAY)) {
+		if (!(v_def_array = v_def_iter = _get_def_array_values(handle->cft, def)))
+			return_0;
+		do {
+			/* iterate over each element of the array and check its value */
+			if ((v->type != v_def_iter->type) ||
+			    _check_value_differs_from_default(handle, v, def, v_def_iter))
+				break;
+			v_def_iter = v_def_iter->next;
+			v = v->next;
+		} while (v_def_iter && v);
+		diff = v || v_def_iter;
+		dm_pool_free(handle->cft->mem, v_def_array);
+	} else {
+		switch (v->type) {
+			case DM_CFG_INT:
+				/* int value can be a real int but it can also represent bool */
+				i = v_def ? v_def->v.i
+					  : def->type & CFG_TYPE_BOOL ?
+						cfg_def_get_default_value(handle->cmd, def, CFG_TYPE_BOOL, NULL) :
+						cfg_def_get_default_value(handle->cmd, def, CFG_TYPE_INT, NULL);
+				diff = i != v->v.i;
+				break;
+			case DM_CFG_FLOAT:
+				f = v_def ? v_def->v.f
+					  : cfg_def_get_default_value(handle->cmd, def, CFG_TYPE_FLOAT, NULL);
+				diff = fabs(f - v->v.f) < FLT_EPSILON;
+				break;
+			case DM_CFG_STRING:
+				/* string value can be a real string but it can also represent bool */
+				if (v_def ? v_def->type == DM_CFG_INT : def->type == CFG_TYPE_BOOL) {
+					i = v_def ? v_def->v.i
+						  : cfg_def_get_default_value(handle->cmd, def, CFG_TYPE_BOOL, NULL);
+					diff = i != v->v.i;
+				} else {
+					str = v_def ? v_def->v.str
+						    : cfg_def_get_default_value(handle->cmd, def, CFG_TYPE_STRING, NULL);
+					diff = strcmp(str, v->v.str);
+				}
+				break;
+			default:
+				log_error(INTERNAL_ERROR "inconsistent state reached in _check_value_differs_from_default");
+				return 0;
+		}
+	}
+out:
+	if (diff) {
+		/* mark whole path from bottom to top with CFG_DIFF */
+		for (id = def->id; id && !(handle->status[id] & CFG_DIFF); id = _cfg_def_items[id].parent)
+			handle->status[id] |= CFG_DIFF;
+	}
+
+	return diff;
+}
+
 static int _config_def_check_node_value(struct cft_check_handle *handle,
 					const char *rp, const struct dm_config_value *v,
 					const cfg_def_item_t *def)
 {
+	const struct dm_config_value *v_iter;
+
 	if (!v) {
 		if (def->type != CFG_TYPE_SECTION) {
 			_log_type_error(rp, CFG_TYPE_SECTION, def->type, handle->suppress_messages);
@@ -700,11 +776,15 @@ static int _config_def_check_node_value(struct cft_check_handle *handle,
 		}
 	}
 
+	v_iter = v;
 	do {
-		if (!_config_def_check_node_single_value(handle, rp, v, def))
+		if (!_config_def_check_node_single_value(handle, rp, v_iter, def))
 			return 0;
-		v = v->next;
-	} while (v);
+		v_iter = v_iter->next;
+	} while (v_iter);
+
+	if (handle->check_diff)
+		_check_value_differs_from_default(handle, v, def, NULL);
 
 	return 1;
 }
@@ -819,7 +899,7 @@ int config_def_check(struct cft_check_handle *handle)
 
 	/* Clear 'used' and 'valid' status flags. */
 	for (id = 0; id < CFG_COUNT; id++)
-		handle->status[id] &= ~(CFG_USED | CFG_VALID);
+		handle->status[id] &= ~(CFG_USED | CFG_VALID | CFG_DIFF);
 
 	/*
 	 * Create a hash of all possible configuration
diff --git a/lib/config/config.h b/lib/config/config.h
index e5bcab8..5d67e85 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -141,6 +141,8 @@ struct config_def_tree_spec {
 #define CFG_USED		0x01
 /* flag to mark the item as valid in a config tree instance during validation */
 #define CFG_VALID		0x02
+/* flag to mark the item as having the value different from default one */
+#define CFG_DIFF		0x04
 
 /*
  * Register ID for each possible item in the configuration tree.
@@ -171,6 +173,7 @@ struct cft_check_handle {
 	unsigned force_check:1;		/* force check even if disabled by config/checks setting */
 	unsigned skip_if_checked:1;	/* skip the check if already done before - return last state */
 	unsigned suppress_messages:1;	/* suppress messages during the check if config item is found invalid */
+	unsigned check_diff:1;		/* check if the value used differs from default one */
 	uint8_t status[CFG_COUNT];	/* flags for each configuration item - the result of the check */
 };
 


