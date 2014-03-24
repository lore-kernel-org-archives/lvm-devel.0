From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 24 Mar 2014 14:36:25 +0000 (UTC)
Subject: master - cleanup: move _get_def_array_values fn
Message-ID: <20140324143625.708E760DA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=630e0af14e65a860ee941adb2422628bec5ec95c
Commit:        630e0af14e65a860ee941adb2422628bec5ec95c
Parent:        c595b20e56f21505e8380c9b00801639143ee945
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 24 13:21:41 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 24 15:20:19 2014 +0100

cleanup: move _get_def_array_values fn

So we can use reuse it for the code that will follow...
---
 lib/config/config.c |  182 +++++++++++++++++++++++++-------------------------
 1 files changed, 91 insertions(+), 91 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index ba1e280..425d3c6 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -537,6 +537,97 @@ static void _log_type_error(const char *path, cfg_def_type_t actual,
 					     actual_type_name, expected_type_name);
 }
 
+static struct dm_config_value *_get_def_array_values(struct dm_config_tree *cft,
+						     const cfg_def_item_t *def)
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
+			return NULL;
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
+				if (!(r = dm_pool_strdup(cft->mem, token + 1))) {
+					dm_free(enc_value);
+					log_error("Failed to duplicate token for default "
+						  "array value of %s.", def->name);
+					return NULL;
+				}
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
 static int _config_def_check_node_single_value(struct cft_check_handle *handle,
 					       const char *rp, const struct dm_config_value *v,
 					       const cfg_def_item_t *def)
@@ -1214,97 +1305,6 @@ int config_write(struct dm_config_tree *cft,
 	return r;
 }
 
-static struct dm_config_value *_get_def_array_values(struct dm_config_tree *cft,
-						     cfg_def_item_t *def)
-{
-	char *enc_value, *token, *p, *r;
-	struct dm_config_value *array = NULL, *v = NULL, *oldv = NULL;
-
-	if (!def->default_value.v_CFG_TYPE_STRING) {
-		if (!(array = dm_config_create_value(cft))) {
-			log_error("Failed to create default empty array for %s.", def->name);
-			return NULL;
-		}
-		array->type = DM_CFG_EMPTY_ARRAY;
-		return array;
-	}
-
-	if (!(p = token = enc_value = dm_strdup(def->default_value.v_CFG_TYPE_STRING))) {
-		log_error("_get_def_array_values: dm_strdup failed");
-		return NULL;
-	}
-	/* Proper value always starts with '#'. */
-	if (token[0] != '#')
-		goto bad;
-
-	while (token) {
-		/* Move to type identifier. Error on no char. */
-		token++;
-		if (!token[0])
-			goto bad;
-
-		/* Move to the actual value and decode any "##" into "#". */
-		p = token + 1;
-		while ((p = strchr(p, '#')) && p[1] == '#') {
-			memmove(p, p + 1, strlen(p));
-			p++;
-		}
-		/* Separate the value out of the whole string. */
-		if (p)
-			p[0] = '\0';
-
-		if (!(v = dm_config_create_value(cft))) {
-			log_error("Failed to create default config array value for %s.", def->name);
-			dm_free(enc_value);
-			return NULL;
-		}
-		if (oldv)
-			oldv->next = v;
-		if (!array)
-			array = v;
-
-		switch (toupper(token[0])) {
-			case 'I':
-			case 'B':
-				v->v.i = strtoll(token + 1, &r, 10);
-				if (*r)
-					goto bad;
-				v->type = DM_CFG_INT;
-				break;
-			case 'F':
-				v->v.f = strtod(token + 1, &r);
-				if (*r)
-					goto bad;
-				v->type = DM_CFG_FLOAT;
-				break;
-			case 'S':
-				if (!(r = dm_pool_strdup(cft->mem, token + 1))) {
-					dm_free(enc_value);
-					log_error("Failed to duplicate token for default "
-						  "array value of %s.", def->name);
-					return NULL;
-				}
-				v->v.str = r;
-				v->type = DM_CFG_STRING;
-				break;
-			default:
-				goto bad;
-		}
-
-		oldv = v;
-		token = p;
-	}
-
-	dm_free(enc_value);
-	return array;
-bad:
-	log_error(INTERNAL_ERROR "Default array value malformed for \"%s\", "
-		  "value: \"%s\", token: \"%s\".", def->name,
-		  def->default_value.v_CFG_TYPE_STRING, token);
-	dm_free(enc_value);
-	return NULL;
-}
-
 static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 					    struct config_def_tree_spec *spec,
 					    struct dm_config_node *parent,


