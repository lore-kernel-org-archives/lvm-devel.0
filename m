From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 2 Jul 2018 04:27:20 -0400
Subject: master - vdo: enhance status parser
Message-ID: <201807020827.w628RKlA026041@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c96400b6c7b8ba5124c045a2ae9475e3224ec284
Commit:        c96400b6c7b8ba5124c045a2ae9475e3224ec284
Parent:        c1a6b10d09aae6179e4f08c7d8c03d5e3068ad94
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 27 16:18:53 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 2 10:25:35 2018 +0200

vdo: enhance status parser

Add support for using mempool for allocations inside status parser.
Convert some string pointers to arrays.
Reindent tabs.
---
 device_mapper/vdo/status.c |  195 +++++++++++++++++++++-----------------------
 device_mapper/vdo/target.h |    5 +-
 test/unit/vdo_t.c          |    4 +-
 3 files changed, 98 insertions(+), 106 deletions(-)

diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
index f423ca1..7323a35 100644
--- a/device_mapper/vdo/status.c
+++ b/device_mapper/vdo/status.c
@@ -10,28 +10,14 @@
 
 //----------------------------------------------------------------
 
-static char *_tok_cpy(const char *b, const char *e)
-{
-	char *new = malloc((e - b) + 1);
-	char *ptr = new;
-
-	if (new) {
-        	while (b != e)
-                	*ptr++ = *b++;
-                *ptr = '\0';
-	}
-
-	return new;
-}
-
 static bool _tok_eq(const char *b, const char *e, const char *str)
 {
 	while (b != e) {
 		if (!*str || *b != *str)
-        		return false;
+			return false;
 
-        	b++;
-        	str++;
+		b++;
+		str++;
 	}
 
 	return !*str;
@@ -39,22 +25,22 @@ static bool _tok_eq(const char *b, const char *e, const char *str)
 
 static bool _parse_operating_mode(const char *b, const char *e, void *context)
 {
-	static struct {
-        	const char *str;
-        	enum vdo_operating_mode mode;
+	static const struct {
+		const char str[12];
+		enum vdo_operating_mode mode;
 	} _table[] = {
-        	{"recovering", VDO_MODE_RECOVERING},
-        	{"read-only", VDO_MODE_READ_ONLY},
-        	{"normal", VDO_MODE_NORMAL}
+		{"recovering", VDO_MODE_RECOVERING},
+		{"read-only", VDO_MODE_READ_ONLY},
+		{"normal", VDO_MODE_NORMAL}
 	};
 
-        enum vdo_operating_mode *r = context;
+	enum vdo_operating_mode *r = context;
 	unsigned i;
 	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
-        	if (_tok_eq(b, e, _table[i].str)) {
-                	*r = _table[i].mode;
-                	return true;
-        	}
+		if (_tok_eq(b, e, _table[i].str)) {
+			*r = _table[i].mode;
+			return true;
+		}
 	}
 
 	return false;
@@ -62,21 +48,21 @@ static bool _parse_operating_mode(const char *b, const char *e, void *context)
 
 static bool _parse_compression_state(const char *b, const char *e, void *context)
 {
-	static struct {
-        	const char *str;
-        	enum vdo_compression_state state;
+	static const struct {
+		const char str[8];
+		enum vdo_compression_state state;
 	} _table[] = {
-        	{"online", VDO_COMPRESSION_ONLINE},
-        	{"offline", VDO_COMPRESSION_OFFLINE}
+		{"online", VDO_COMPRESSION_ONLINE},
+		{"offline", VDO_COMPRESSION_OFFLINE}
 	};
 
-        enum vdo_compression_state *r = context;
+	enum vdo_compression_state *r = context;
 	unsigned i;
 	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
-        	if (_tok_eq(b, e, _table[i].str)) {
-                	*r = _table[i].state;
-                	return true;
-        	}
+		if (_tok_eq(b, e, _table[i].str)) {
+			*r = _table[i].state;
+			return true;
+		}
 	}
 
 	return false;
@@ -84,55 +70,55 @@ static bool _parse_compression_state(const char *b, const char *e, void *context
 
 static bool _parse_recovering(const char *b, const char *e, void *context)
 {
-        bool *r = context;
+	bool *r = context;
 
 	if (_tok_eq(b, e, "recovering"))
 		*r = true;
 
 	else if (_tok_eq(b, e, "-"))
-        	*r = false;
+		*r = false;
 
-        else
-        	return false;
+	else
+		return false;
 
-        return true;
+	return true;
 }
 
 static bool _parse_index_state(const char *b, const char *e, void *context)
 {
-        static struct {
-                const char *str;
-                enum vdo_index_state state;
-        } _table[] = {
-                {"error", VDO_INDEX_ERROR},
-                {"closed", VDO_INDEX_CLOSED},
-                {"opening", VDO_INDEX_OPENING},
-                {"closing", VDO_INDEX_CLOSING},
-                {"offline", VDO_INDEX_OFFLINE},
-                {"online", VDO_INDEX_ONLINE},
-                {"unknown", VDO_INDEX_UNKNOWN}
-        };
-
-        enum vdo_index_state *r = context;
+	static const struct {
+		const char str[8];
+		enum vdo_index_state state;
+	} _table[] = {
+		{"error", VDO_INDEX_ERROR},
+		{"closed", VDO_INDEX_CLOSED},
+		{"opening", VDO_INDEX_OPENING},
+		{"closing", VDO_INDEX_CLOSING},
+		{"offline", VDO_INDEX_OFFLINE},
+		{"online", VDO_INDEX_ONLINE},
+		{"unknown", VDO_INDEX_UNKNOWN}
+	};
+
+	enum vdo_index_state *r = context;
 	unsigned i;
 	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
-        	if (_tok_eq(b, e, _table[i].str)) {
-                	*r = _table[i].state;
-                	return true;
-        	}
+		if (_tok_eq(b, e, _table[i].str)) {
+			*r = _table[i].state;
+			return true;
+		}
 	}
 
-        return false;
+	return false;
 }
 
 static bool _parse_uint64(const char *b, const char *e, void *context)
 {
-        uint64_t *r = context, n;
+	uint64_t *r = context, n;
 
 	n = 0;
 	while (b != e) {
-        	if (!isdigit(*b))
-                	return false;
+		if (!isdigit(*b))
+			return false;
 
 		n = (n * 10) + (*b - '0');
 		b++;
@@ -145,81 +131,82 @@ static bool _parse_uint64(const char *b, const char *e, void *context)
 static const char *_eat_space(const char *b, const char *e)
 {
 	while (b != e && isspace(*b))
-        	b++;
+		b++;
 
-        return b;
+	return b;
 }
 
 static const char *_next_tok(const char *b, const char *e)
 {
-        const char *te = b;
+	const char *te = b;
 	while (te != e && !isspace(*te))
-        	te++;
+		te++;
 
-        return te == b ? NULL : te;
+	return te == b ? NULL : te;
 }
 
 static void _set_error(struct vdo_status_parse_result *result, const char *fmt, ...)
-	__attribute__ ((format(printf, 2, 3)));
+__attribute__ ((format(printf, 2, 3)));
 
 static void _set_error(struct vdo_status_parse_result *result, const char *fmt, ...)
 {
-        va_list ap;
+	va_list ap;
 
-        va_start(ap, fmt);
+	va_start(ap, fmt);
 	vsnprintf(result->error, sizeof(result->error), fmt, ap);
-        va_end(ap);
+	va_end(ap);
 }
 
 static bool _parse_field(const char **b, const char *e,
-                         bool (*p_fn)(const char *, const char *, void *),
-                         void *field, const char *field_name,
-                         struct vdo_status_parse_result *result)
+			 bool (*p_fn)(const char *, const char *, void *),
+			 void *field, const char *field_name,
+			 struct vdo_status_parse_result *result)
 {
-        const char *te;
+	const char *te;
 
-        te = _next_tok(*b, e);
-        if (!te) {
-                _set_error(result, "couldn't get token for '%s'", field_name);
-                return false;
-        }
+	te = _next_tok(*b, e);
+	if (!te) {
+		_set_error(result, "couldn't get token for '%s'", field_name);
+		return false;
+	}
 
-        if (!p_fn(*b, te, field)) {
-                _set_error(result, "couldn't parse '%s'", field_name);
-                return false;
-        }
+	if (!p_fn(*b, te, field)) {
+		_set_error(result, "couldn't parse '%s'", field_name);
+		return false;
+	}
 
 	*b = _eat_space(te, e);
-        return true;
+	return true;
 
 }
 
-bool vdo_status_parse(const char *input, struct vdo_status_parse_result *result)
+bool vdo_status_parse(struct dm_pool *mem, const char *input,
+		      struct vdo_status_parse_result *result)
 {
 	const char *b = b = input;
 	const char *e = input + strlen(input);
 	const char *te;
-	struct vdo_status *s = malloc(sizeof(*s));
+	struct vdo_status *s;
+
+	s = (!mem) ? malloc(sizeof(*s)) : dm_pool_zalloc(mem, sizeof(*s));
 
 	if (!s) {
-        	_set_error(result, "out of memory");
-        	return false;
+		_set_error(result, "out of memory");
+		return false;
 	}
 
 	b = _eat_space(b, e);
 	te = _next_tok(b, e);
 	if (!te) {
-        	_set_error(result, "couldn't get token for device");
-        	free(s);
-        	return false;
+		_set_error(result, "couldn't get token for device");
+		goto bad;
 	}
 
-	s->device = _tok_cpy(b, te);
-	if (!s->device) {
+	if (!(s->device = (!mem) ? malloc((e - b) + 1) : dm_pool_alloc(mem, (e - b) + 1))) {
 		_set_error(result, "out of memory");
-		free(s);
-		return false;
+		goto bad;
 	}
+	dm_strncpy(s->device, b, te - b);
 
 	b = _eat_space(te, e);
 
@@ -237,12 +224,14 @@ bool vdo_status_parse(const char *input, struct vdo_status_parse_result *result)
 		goto bad;
 	}
 
-        result->status = s;
-        return true;
+	result->status = s;
+	return true;
 
 bad:
-	free(s->device);
-	free(s);
+	if (s && !mem) {
+		free(s->device);
+		free(s);
+	}
 	return false;
 }
 
diff --git a/device_mapper/vdo/target.h b/device_mapper/vdo/target.h
index 3137e2c..edf72a6 100644
--- a/device_mapper/vdo/target.h
+++ b/device_mapper/vdo/target.h
@@ -60,8 +60,11 @@ struct vdo_status_parse_result {
 	struct vdo_status *status;
 };
 
+struct dm_pool;
+
 // Parses the status line from the kernel target.
-bool vdo_status_parse(const char *input, struct vdo_status_parse_result *result);
+bool vdo_status_parse(struct dm_pool *mem, const char *input,
+		      struct vdo_status_parse_result *result);
 
 //----------------------------------------------------------------
 
diff --git a/test/unit/vdo_t.c b/test/unit/vdo_t.c
index a26c0b9..7355928 100644
--- a/test/unit/vdo_t.c
+++ b/test/unit/vdo_t.c
@@ -91,7 +91,7 @@ static void _check_good(struct example_good *es, unsigned count)
                 struct example_good *e = es + i;
                 struct vdo_status_parse_result pr;
 
-                T_ASSERT(vdo_status_parse(e->input, &pr));
+                T_ASSERT(vdo_status_parse(NULL, e->input, &pr));
 #if 0
                 _print_status(stderr, pr.status);
                 fprintf(stderr, "\n");
@@ -116,7 +116,7 @@ static void _check_bad(struct example_bad *es, unsigned count)
                 struct example_bad *e = es + i;
                 struct vdo_status_parse_result pr;
 
-                T_ASSERT(!vdo_status_parse(e->input, &pr));
+                T_ASSERT(!vdo_status_parse(NULL, e->input, &pr));
                 T_ASSERT(!strcmp(e->reason, pr.error));
         }
 }


