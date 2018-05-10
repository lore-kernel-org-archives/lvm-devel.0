From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 10 May 2018 08:05:34 -0400
Subject: master - vdo: get status parser compiling
Message-ID: <201805101205.w4AC5Y8c032486@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6abc3f10aea3e18a34e9bf1e5995ffa4cb496a5e
Commit:        6abc3f10aea3e18a34e9bf1e5995ffa4cb496a5e
Parent:        11d9b0cae7ef451e282ad17f6085450afc91b2ca
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 2 11:15:35 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 2 11:15:35 2018 +0100

vdo: get status parser compiling

---
 device-mapper/vdo/status.c |   75 +++++++++++++++++++++++++++++++------------
 device-mapper/vdo/target.h |    2 +-
 2 files changed, 55 insertions(+), 22 deletions(-)

diff --git a/device-mapper/vdo/status.c b/device-mapper/vdo/status.c
index ccebc83..895ebc4 100644
--- a/device-mapper/vdo/status.c
+++ b/device-mapper/vdo/status.c
@@ -3,11 +3,13 @@
 // For DM_ARRAY_SIZE!
 #include "libdevmapper.h"
 
+#include <ctype.h>
 #include <stdlib.h>
+#include <string.h>
 
 //----------------------------------------------------------------
 
-static const char *_tok_cpy(const char *b, const char *e, const char *str)
+static char *_tok_cpy(const char *b, const char *e)
 {
 	char *new = malloc((e - b) + 1);
 	char *ptr = new;
@@ -32,8 +34,7 @@ static bool _tok_eq(const char *b, const char *e, const char *str)
 	return !*str;
 }
 
-static bool _parse_operating_mode(const char *b, const char *e,
-                                  enum vdo_operating_mode *r)
+static bool _parse_operating_mode(const char *b, const char *e, void *context)
 {
 	static struct {
         	const char *str;
@@ -44,6 +45,7 @@ static bool _parse_operating_mode(const char *b, const char *e,
         	{"normal", VDO_MODE_NORMAL}
 	};
 
+        enum vdo_operating_mode *r = context;
 	unsigned i;
 	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
         	if (_tok_eq(b, e, _table[i].str)) {
@@ -55,8 +57,7 @@ static bool _parse_operating_mode(const char *b, const char *e,
 	return false;
 }
 
-static bool _parse_compression_state(const char *b, const char *e,
-                                     enum vdo_compression_state *r)
+static bool _parse_compression_state(const char *b, const char *e, void *context)
 {
 	static struct {
         	const char *str;
@@ -66,6 +67,7 @@ static bool _parse_compression_state(const char *b, const char *e,
         	{"offline", VDO_COMPRESSION_OFFLINE}
 	};
 
+        enum vdo_compression_state *r = context;
 	unsigned i;
 	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
         	if (_tok_eq(b, e, _table[i].str)) {
@@ -77,8 +79,10 @@ static bool _parse_compression_state(const char *b, const char *e,
 	return false;
 }
 
-static bool _parse_recovering(const char *b, const char *e, bool *r)
+static bool _parse_recovering(const char *b, const char *e, void *context)
 {
+        bool *r = context;
+
 	if (_tok_eq(b, e, "recovering"))
 		*r = true;
 
@@ -91,8 +95,7 @@ static bool _parse_recovering(const char *b, const char *e, bool *r)
         return true;
 }
 
-static bool _parse_index_state(const char *b, const char *e,
-                               enum vdo_index_state *r)
+static bool _parse_index_state(const char *b, const char *e, void *context)
 {
         static struct {
                 const char *str;
@@ -107,6 +110,7 @@ static bool _parse_index_state(const char *b, const char *e,
                 {"unknown", VDO_INDEX_UNKNOWN}
         };
 
+        enum vdo_index_state *r = context;
 	unsigned i;
 	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
         	if (_tok_eq(b, e, _table[i].str)) {
@@ -118,6 +122,23 @@ static bool _parse_index_state(const char *b, const char *e,
         return false;
 }
 
+static bool _parse_uint64(const char *b, const char *e, void *context)
+{
+        uint64_t *r = context, n;
+
+	n = 0;
+	while (b != e) {
+        	if (!isdigit(*b))
+                	return false;
+
+		n = (n << 1) + (*b - '0');
+		b++;
+	}
+
+	*r = n;
+	return true;
+}
+
 static const char *_eat_space(const char *b, const char *e)
 {
 	while (b != e && isspace(*b))
@@ -134,8 +155,20 @@ static const char *_next_tok(const char *b, const char *e)
         return b == e ? NULL : b;
 }
 
+static void _set_error(struct parse_result *result, const char *fmt, ...)
+	__attribute__ ((format(printf, 2, 3)));
+
+static void _set_error(struct parse_result *result, const char *fmt, ...)
+{
+        va_list ap;
+
+        va_start(ap, fmt);
+	vsnprintf(result->error, sizeof(result->error), fmt, ap);
+        va_end(ap);
+}
+
 static bool _parse_field(const char **b, const char *e,
-                         bool (*p_fn)(const char *, const char *, void *)
+                         bool (*p_fn)(const char *, const char *, void *),
                          void *field, const char *field_name,
                          struct parse_result *result)
 {
@@ -143,53 +176,53 @@ static bool _parse_field(const char **b, const char *e,
 
         te = _next_tok(*b, e);
         if (!te) {
-                snprintf(result->error, sizeof(result->error),
-                         "couldn't get token for '%s'", field_name);
+                _set_error(result, "couldn't get token for '%s'", field_name);
                 return false;
         }
 
-        if (!p_fn(*b, te, field) {
-                snprintf(result->error, sizeof(result->error),
-                         "couldn't parse '%s'", field_name);
+        if (!p_fn(*b, te, field)) {
+                _set_error(result, "couldn't parse '%s'", field_name);
                 return false;
         }
 
-	*b = _eat_space(te);
+	*b = _eat_space(te, e);
         return true;
 
 }
 
 bool parse_vdo_status(const char *input, struct parse_result *result)
 {
-	const char *b = _eat_space(input);
+	const char *b = b = input;
 	const char *e = input + strlen(input);
 	const char *te;
 	struct vdo_status *s = malloc(sizeof(*s));
 
 	if (!s) {
-        	result->error = "out of memory";
+        	_set_error(result, "out of memory");
         	return false;
 	}
 
+	b = _eat_space(b, e);
 	te = _next_tok(b, e);
 	if (!te) {
-        	result->error = "couldn't get token for device";
+        	_set_error(result, "couldn't get token for device");
         	free(s);
         	return false;
 	}
 
 	s->device = _tok_cpy(b, te);
 	if (!s->device) {
-		result->error = "out of memory";
+		_set_error(result, "out of memory");
 		free(s);
 		return false;
 	}
 
-	b = _eat_space(te);
+	b = _eat_space(te, e);
 
 #define XX(p, f, fn) if (!_parse_field(&b, e, p, f, fn, result)) goto bad;
+	XX(_parse_operating_mode, &s->operating_mode, "operating mode");
 	XX(_parse_recovering, &s->recovering, "recovering");
-	XX(_parse_index, &s->index_state, "index state");
+	XX(_parse_index_state, &s->index_state, "index state");
 	XX(_parse_compression_state, &s->compression_state, "compression state");
 	XX(_parse_uint64, &s->used_blocks, "used blocks");
 	XX(_parse_uint64, &s->total_blocks, "total blocks");
diff --git a/device-mapper/vdo/target.h b/device-mapper/vdo/target.h
index e3c6788..118ec93 100644
--- a/device-mapper/vdo/target.h
+++ b/device-mapper/vdo/target.h
@@ -42,7 +42,7 @@ enum vdo_index_state {
 };
 
 struct vdo_status {
-	const char *device;
+	char *device;
 	enum vdo_operating_mode operating_mode;
 	bool recovering;
 	enum vdo_index_state index_state;


