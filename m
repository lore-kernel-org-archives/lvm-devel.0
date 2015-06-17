From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 17 Jun 2015 18:08:03 +0000 (UTC)
Subject: master - libdaemon: move compare_config to lib
Message-ID: <20150617180803.672DD60094@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd1376ebefa3dd66baff5da161de02b869a734a7
Commit:        fd1376ebefa3dd66baff5da161de02b869a734a7
Parent:        0a203070f5189a53f764e1e6e960ac70acfad5a9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 17 13:06:37 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 17 13:07:52 2015 -0500

libdaemon: move compare_config to lib

so it can be used elsewhere.
---
 daemons/lvmetad/lvmetad-core.c |   57 ----------------------------------------
 libdaemon/client/config-util.c |   57 ++++++++++++++++++++++++++++++++++++++++
 libdaemon/client/config-util.h |    2 +
 3 files changed, 59 insertions(+), 57 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 57a86e4..dc0c92a 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -26,9 +26,6 @@
 #include <stdint.h>
 #include <unistd.h>
 
-#include <math.h>  /* fabs() */
-#include <float.h> /* DBL_EPSILON */
-
 #define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
 
 typedef struct {
@@ -569,60 +566,6 @@ bad:
 	return reply_fail("out of memory");
 }
 
-/* Test if the doubles are close enough to be considered equal */
-static int close_enough(double d1, double d2)
-{
-	return fabs(d1 - d2) < DBL_EPSILON;
-}
-
-static int compare_value(struct dm_config_value *a, struct dm_config_value *b)
-{
-	int r = 0;
-
-	if (a->type > b->type)
-		return 1;
-	if (a->type < b->type)
-		return -1;
-
-	switch (a->type) {
-	case DM_CFG_STRING: r = strcmp(a->v.str, b->v.str); break;
-	case DM_CFG_FLOAT: r = close_enough(a->v.f, b->v.f) ? 0 : (a->v.f > b->v.f) ? 1 : -1; break;
-	case DM_CFG_INT: r = (a->v.i == b->v.i) ? 0 : (a->v.i > b->v.i) ? 1 : -1; break;
-	case DM_CFG_EMPTY_ARRAY: return 0;
-	}
-
-	if (r == 0 && a->next && b->next)
-		r = compare_value(a->next, b->next);
-	return r;
-}
-
-static int compare_config(struct dm_config_node *a, struct dm_config_node *b)
-{
-	int result = 0;
-	if (a->v && b->v)
-		result = compare_value(a->v, b->v);
-	if (a->v && !b->v)
-		result = 1;
-	if (!a->v && b->v)
-		result = -1;
-	if (a->child && b->child)
-		result = compare_config(a->child, b->child);
-
-	if (result) {
-		// DEBUGLOG("config inequality at %s / %s", a->key, b->key);
-		return result;
-	}
-
-	if (a->sib && b->sib)
-		result = compare_config(a->sib, b->sib);
-	if (a->sib && !b->sib)
-		result = 1;
-	if (!a->sib && b->sib)
-		result = -1;
-
-	return result;
-}
-
 static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_pvids);
 
 enum update_pvid_mode { UPDATE_ONLY, REMOVE_EMPTY, MARK_OUTDATED };
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 4ebbe1b..067c912 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -20,6 +20,9 @@
 #include <string.h>
 #include <unistd.h>
 
+#include <math.h>  /* fabs() */
+#include <float.h> /* DBL_EPSILON */
+
 int buffer_append_vf(struct buffer *buf, va_list ap)
 {
 	char *append;
@@ -277,6 +280,60 @@ struct dm_config_node *config_make_nodes(struct dm_config_tree *cft,
 	return res;
 }
 
+/* Test if the doubles are close enough to be considered equal */
+static int close_enough(double d1, double d2)
+{
+	return fabs(d1 - d2) < DBL_EPSILON;
+}
+
+static int compare_value(struct dm_config_value *a, struct dm_config_value *b)
+{
+	int r = 0;
+
+	if (a->type > b->type)
+		return 1;
+	if (a->type < b->type)
+		return -1;
+
+	switch (a->type) {
+	case DM_CFG_STRING: r = strcmp(a->v.str, b->v.str); break;
+	case DM_CFG_FLOAT: r = close_enough(a->v.f, b->v.f) ? 0 : (a->v.f > b->v.f) ? 1 : -1; break;
+	case DM_CFG_INT: r = (a->v.i == b->v.i) ? 0 : (a->v.i > b->v.i) ? 1 : -1; break;
+	case DM_CFG_EMPTY_ARRAY: return 0;
+	}
+
+	if (r == 0 && a->next && b->next)
+		r = compare_value(a->next, b->next);
+	return r;
+}
+
+int compare_config(struct dm_config_node *a, struct dm_config_node *b)
+{
+	int result = 0;
+	if (a->v && b->v)
+		result = compare_value(a->v, b->v);
+	if (a->v && !b->v)
+		result = 1;
+	if (!a->v && b->v)
+		result = -1;
+	if (a->child && b->child)
+		result = compare_config(a->child, b->child);
+
+	if (result) {
+		// DEBUGLOG("config inequality at %s / %s", a->key, b->key);
+		return result;
+	}
+
+	if (a->sib && b->sib)
+		result = compare_config(a->sib, b->sib);
+	if (a->sib && !b->sib)
+		result = 1;
+	if (!a->sib && b->sib)
+		result = -1;
+
+	return result;
+}
+
 int buffer_realloc(struct buffer *buf, int needed)
 {
 	char *new;
diff --git a/libdaemon/client/config-util.h b/libdaemon/client/config-util.h
index 58468ef..3e0a23f 100644
--- a/libdaemon/client/config-util.h
+++ b/libdaemon/client/config-util.h
@@ -46,6 +46,8 @@ struct dm_config_node *make_config_node(struct dm_config_tree *cft,
 					struct dm_config_node *parent,
 					struct dm_config_node *pre_sib);
 
+int compare_config(struct dm_config_node *a, struct dm_config_node *b);
+
 struct dm_config_node *make_text_node(struct dm_config_tree *cft,
 				      const char *key,
 				      const char *value,


