From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 04:35:22 -0400
Subject: master - tests: update vdo unit test to dm prefix
Message-ID: <201807090835.w698ZMB9024708@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f3eff8eaecdb6e8f97b3904d5c43d36700709f3
Commit:        5f3eff8eaecdb6e8f97b3904d5c43d36700709f3
Parent:        9b6b4f14d89c661683b2095999126e652fb92f53
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 10:05:06 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 10:30:34 2018 +0200

tests: update vdo unit test to dm prefix

Update prefix and reindent.
---
 test/unit/vdo_t.c |  264 ++++++++++++++++++++++++++--------------------------
 1 files changed, 132 insertions(+), 132 deletions(-)

diff --git a/test/unit/vdo_t.c b/test/unit/vdo_t.c
index 7355928..27ad26b 100644
--- a/test/unit/vdo_t.c
+++ b/test/unit/vdo_t.c
@@ -17,7 +17,7 @@
 
 //----------------------------------------------------------------
 
-static bool _status_eq(struct vdo_status *lhs, struct vdo_status *rhs)
+static bool _status_eq(struct dm_vdo_status *lhs, struct dm_vdo_status *rhs)
 {
 	return !strcmp(lhs->device, rhs->device) &&
 		(lhs->operating_mode == rhs->operating_mode) &&
@@ -29,49 +29,49 @@ static bool _status_eq(struct vdo_status *lhs, struct vdo_status *rhs)
 }
 
 #if 0
-static const char *_op_mode(enum vdo_operating_mode m)
+static const char *_op_mode(enum dm_vdo_operating_mode m)
 {
-        switch (m) {
-        case VDO_MODE_RECOVERING:
-                return "recovering";
-        case VDO_MODE_READ_ONLY:
-                return "read-only";
-        case VDO_MODE_NORMAL:
-                return "normal";
-        }
-
-        return "<unknown>";
+	switch (m) {
+	case DM_VDO_MODE_RECOVERING:
+		return "recovering";
+	case DM_VDO_MODE_READ_ONLY:
+		return "read-only";
+	case DM_VDO_MODE_NORMAL:
+		return "normal";
+	}
+
+	return "<unknown>";
 }
 
-static const char *_index_state(enum vdo_index_state is)
+static const char *_index_state(enum dm_vdo_index_state is)
 {
-        switch (is) {
-	case VDO_INDEX_ERROR:
-        	return "error";
-        case VDO_INDEX_CLOSED:
-                return "closed";
-        case VDO_INDEX_OPENING:
-                return "opening";
-        case VDO_INDEX_CLOSING:
-                return "closing";
-        case VDO_INDEX_OFFLINE:
-                return "offline";
-        case VDO_INDEX_ONLINE:
-                return "online";
-        case VDO_INDEX_UNKNOWN:
-                return "unknown";
-        }
-
-        return "<unknown>";
+	switch (is) {
+	case DM_VDO_INDEX_ERROR:
+		return "error";
+	case DM_VDO_INDEX_CLOSED:
+		return "closed";
+	case DM_VDO_INDEX_OPENING:
+		return "opening";
+	case DM_VDO_INDEX_CLOSING:
+		return "closing";
+	case DM_VDO_INDEX_OFFLINE:
+		return "offline";
+	case DM_VDO_INDEX_ONLINE:
+		return "online";
+	case DM_VDO_INDEX_UNKNOWN:
+		return "unknown";
+	}
+
+	return "<unknown>";
 }
 
-static void _print_status(FILE *stream, struct vdo_status *s)
+static void _print_status(FILE *stream, struct dm_vdo_status *s)
 {
 	fprintf(stream, "<status| %s ", s->device);
 	fprintf(stream, "%s ", _op_mode(s->operating_mode));
 	fprintf(stream, "%s ", s->recovering ? "recovering" : "-");
 	fprintf(stream, "%s ", _index_state(s->index_state));
-	fprintf(stream, "%s ", s->compression_state == VDO_COMPRESSION_ONLINE ? "online" : "offline");
+	fprintf(stream, "%s ", s->compression_state == DM_VDO_COMPRESSION_ONLINE ? "online" : "offline");
 	fprintf(stream, "%llu ", (unsigned long long) s->used_blocks);
 	fprintf(stream, "%llu", (unsigned long long) s->total_blocks);
 	fprintf(stream, ">");
@@ -80,55 +80,55 @@ static void _print_status(FILE *stream, struct vdo_status *s)
 
 struct example_good {
 	const char *input;
-	struct vdo_status status;
+	struct dm_vdo_status status;
 };
 
 static void _check_good(struct example_good *es, unsigned count)
 {
-        unsigned i;
+	unsigned i;
 
-        for (i = 0; i < count; i++) {
-                struct example_good *e = es + i;
-                struct vdo_status_parse_result pr;
+	for (i = 0; i < count; i++) {
+		struct example_good *e = es + i;
+		struct dm_vdo_status_parse_result pr;
 
-                T_ASSERT(vdo_status_parse(NULL, e->input, &pr));
+		T_ASSERT(dm_vdo_status_parse(NULL, e->input, &pr));
 #if 0
-                _print_status(stderr, pr.status);
-                fprintf(stderr, "\n");
-                _print_status(stderr, &e->status);
-                fprintf(stderr, "\n");
+		_print_status(stderr, pr.status);
+		fprintf(stderr, "\n");
+		_print_status(stderr, &e->status);
+		fprintf(stderr, "\n");
 #endif
-                T_ASSERT(_status_eq(&e->status, pr.status));
-                free(pr.status);
-        }
+		T_ASSERT(_status_eq(&e->status, pr.status));
+		free(pr.status);
+	}
 }
 
 struct example_bad {
-        const char *input;
-        const char *reason;
+	const char *input;
+	const char *reason;
 };
 
 static void _check_bad(struct example_bad *es, unsigned count)
 {
-        unsigned i;
+	unsigned i;
 
-        for (i = 0; i < count; i++) {
-                struct example_bad *e = es + i;
-                struct vdo_status_parse_result pr;
+	for (i = 0; i < count; i++) {
+		struct example_bad *e = es + i;
+		struct dm_vdo_status_parse_result pr;
 
-                T_ASSERT(!vdo_status_parse(NULL, e->input, &pr));
-                T_ASSERT(!strcmp(e->reason, pr.error));
-        }
+		T_ASSERT(!dm_vdo_status_parse(NULL, e->input, &pr));
+		T_ASSERT(!strcmp(e->reason, pr.error));
+	}
 }
 
 static void _test_device_names_good(void *fixture)
 {
 	static struct example_good _es[] = {
-                {"foo1234 read-only - error online 0 1234",
-                 {(char *) "foo1234", VDO_MODE_READ_ONLY, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"f read-only - error online 0 1234",
-                 {(char *) "f", VDO_MODE_READ_ONLY, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-        };
+		{"foo1234 read-only - error online 0 1234",
+		{(char *) "foo1234", DM_VDO_MODE_READ_ONLY, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"f read-only - error online 0 1234",
+		{(char *) "f", DM_VDO_MODE_READ_ONLY, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+	};
 
 	_check_good(_es, DM_ARRAY_SIZE(_es));
 }
@@ -136,13 +136,13 @@ static void _test_device_names_good(void *fixture)
 static void _test_operating_mode_good(void *fixture)
 {
 	static struct example_good _es[] = {
-                {"device-name recovering - error online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name read-only - error online 0 1234",
-                 {(char *) "device-name", VDO_MODE_READ_ONLY, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name normal - error online 0 1234",
-                 {(char *) "device-name", VDO_MODE_NORMAL, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-        };
+		{"device-name recovering - error online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name read-only - error online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_READ_ONLY, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name normal - error online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_NORMAL, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+	};
 
 	_check_good(_es, DM_ARRAY_SIZE(_es));
 }
@@ -150,20 +150,20 @@ static void _test_operating_mode_good(void *fixture)
 static void _test_operating_mode_bad(void *fixture)
 {
 	static struct example_bad _es[] = {
-        	{"device-name investigating - error online 0 1234",
-                 "couldn't parse 'operating mode'"}};
+		{"device-name investigating - error online 0 1234",
+		"couldn't parse 'operating mode'"}};
 
-        _check_bad(_es, DM_ARRAY_SIZE(_es));
+	_check_bad(_es, DM_ARRAY_SIZE(_es));
 }
 
 static void _test_recovering_good(void *fixture)
 {
 	static struct example_good _es[] = {
-                {"device-name recovering - error online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name read-only recovering error online 0 1234",
-                 {(char *) "device-name", VDO_MODE_READ_ONLY, true, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-        };
+		{"device-name recovering - error online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name read-only recovering error online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_READ_ONLY, true, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+	};
 
 	_check_good(_es, DM_ARRAY_SIZE(_es));
 }
@@ -171,30 +171,30 @@ static void _test_recovering_good(void *fixture)
 static void _test_recovering_bad(void *fixture)
 {
 	static struct example_bad _es[] = {
-        	{"device-name normal fish error online 0 1234",
-                 "couldn't parse 'recovering'"}};
+		{"device-name normal fish error online 0 1234",
+		"couldn't parse 'recovering'"}};
 
-        _check_bad(_es, DM_ARRAY_SIZE(_es));
+	_check_bad(_es, DM_ARRAY_SIZE(_es));
 }
 
 static void _test_index_state_good(void *fixture)
 {
 	static struct example_good _es[] = {
-                {"device-name recovering - error online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name recovering - closed online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_CLOSED, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name recovering - opening online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_OPENING, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name recovering - closing online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_CLOSING, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name recovering - offline online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_OFFLINE, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name recovering - online online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_ONLINE, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name recovering - unknown online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_UNKNOWN, VDO_COMPRESSION_ONLINE, 0, 1234}},
-        };
+		{"device-name recovering - error online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name recovering - closed online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_CLOSED, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name recovering - opening online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_OPENING, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name recovering - closing online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_CLOSING, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name recovering - offline online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_OFFLINE, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name recovering - online online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_ONLINE, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name recovering - unknown online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_UNKNOWN, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+	};
 
 	_check_good(_es, DM_ARRAY_SIZE(_es));
 }
@@ -202,20 +202,20 @@ static void _test_index_state_good(void *fixture)
 static void _test_index_state_bad(void *fixture)
 {
 	static struct example_bad _es[] = {
-        	{"device-name normal - fish online 0 1234",
-                 "couldn't parse 'index state'"}};
+		{"device-name normal - fish online 0 1234",
+		"couldn't parse 'index state'"}};
 
-        _check_bad(_es, DM_ARRAY_SIZE(_es));
+	_check_bad(_es, DM_ARRAY_SIZE(_es));
 }
 
 static void _test_compression_state_good(void *fixture)
 {
 	static struct example_good _es[] = {
-                {"device-name recovering - error online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name read-only - error offline 0 1234",
-                 {(char *) "device-name", VDO_MODE_READ_ONLY, false, VDO_INDEX_ERROR, VDO_COMPRESSION_OFFLINE, 0, 1234}},
-        };
+		{"device-name recovering - error online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name read-only - error offline 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_READ_ONLY, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_OFFLINE, 0, 1234}},
+	};
 
 	_check_good(_es, DM_ARRAY_SIZE(_es));
 }
@@ -223,24 +223,24 @@ static void _test_compression_state_good(void *fixture)
 static void _test_compression_state_bad(void *fixture)
 {
 	static struct example_bad _es[] = {
-        	{"device-name normal - error fish 0 1234",
-                 "couldn't parse 'compression state'"}};
+		{"device-name normal - error fish 0 1234",
+		"couldn't parse 'compression state'"}};
 
-        _check_bad(_es, DM_ARRAY_SIZE(_es));
+	_check_bad(_es, DM_ARRAY_SIZE(_es));
 }
 
 static void _test_used_blocks_good(void *fixture)
 {
 	static struct example_good _es[] = {
-                {"device-name recovering - error online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name read-only - error offline 1 1234",
-                 {(char *) "device-name", VDO_MODE_READ_ONLY, false, VDO_INDEX_ERROR, VDO_COMPRESSION_OFFLINE, 1, 1234}},
-                {"device-name read-only - error offline 12 1234",
-                 {(char *) "device-name", VDO_MODE_READ_ONLY, false, VDO_INDEX_ERROR, VDO_COMPRESSION_OFFLINE, 12, 1234}},
-                {"device-name read-only - error offline 3456 1234",
-                 {(char *) "device-name", VDO_MODE_READ_ONLY, false, VDO_INDEX_ERROR, VDO_COMPRESSION_OFFLINE, 3456, 1234}},
-        };
+		{"device-name recovering - error online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name read-only - error offline 1 1234",
+		{(char *) "device-name", DM_VDO_MODE_READ_ONLY, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_OFFLINE, 1, 1234}},
+		{"device-name read-only - error offline 12 1234",
+		{(char *) "device-name", DM_VDO_MODE_READ_ONLY, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_OFFLINE, 12, 1234}},
+		{"device-name read-only - error offline 3456 1234",
+		{(char *) "device-name", DM_VDO_MODE_READ_ONLY, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_OFFLINE, 3456, 1234}},
+	};
 
 	_check_good(_es, DM_ARRAY_SIZE(_es));
 }
@@ -248,22 +248,22 @@ static void _test_used_blocks_good(void *fixture)
 static void _test_used_blocks_bad(void *fixture)
 {
 	static struct example_bad _es[] = {
-        	{"device-name normal - error online fish 1234",
-                 "couldn't parse 'used blocks'"}};
+		{"device-name normal - error online fish 1234",
+		"couldn't parse 'used blocks'"}};
 
-        _check_bad(_es, DM_ARRAY_SIZE(_es));
+	_check_bad(_es, DM_ARRAY_SIZE(_es));
 }
 
 static void _test_total_blocks_good(void *fixture)
 {
 	static struct example_good _es[] = {
-                {"device-name recovering - error online 0 1234",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1234}},
-                {"device-name recovering - error online 0 1",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 1}},
-                {"device-name recovering - error online 0 0",
-                 {(char *) "device-name", VDO_MODE_RECOVERING, false, VDO_INDEX_ERROR, VDO_COMPRESSION_ONLINE, 0, 0}},
-        };
+		{"device-name recovering - error online 0 1234",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1234}},
+		{"device-name recovering - error online 0 1",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 1}},
+		{"device-name recovering - error online 0 0",
+		{(char *) "device-name", DM_VDO_MODE_RECOVERING, false, DM_VDO_INDEX_ERROR, DM_VDO_COMPRESSION_ONLINE, 0, 0}},
+	};
 
 	_check_good(_es, DM_ARRAY_SIZE(_es));
 }
@@ -271,18 +271,18 @@ static void _test_total_blocks_good(void *fixture)
 static void _test_total_blocks_bad(void *fixture)
 {
 	static struct example_bad _es[] = {
-        	{"device-name normal - error online 0 fish",
-                 "couldn't parse 'total blocks'"}};
+		{"device-name normal - error online 0 fish",
+		"couldn't parse 'total blocks'"}};
 
-        _check_bad(_es, DM_ARRAY_SIZE(_es));
+	_check_bad(_es, DM_ARRAY_SIZE(_es));
 }
 
 static void _test_status_bad(void *fixture)
 {
-        struct example_bad _bad[] = {
-                {"", "couldn't get token for device"},
-                {"device-name read-only - error online 0 1000 lksd", "too many tokens"}
-        };
+	struct example_bad _bad[] = {
+		{"", "couldn't get token for device"},
+		{"device-name read-only - error online 0 1000 lksd", "too many tokens"}
+	};
 
 	_check_bad(_bad, DM_ARRAY_SIZE(_bad));
 }
@@ -295,8 +295,8 @@ static struct test_suite *_tests(void)
 {
 	struct test_suite *ts = test_suite_create(NULL, NULL);
 	if (!ts) {
-        	fprintf(stderr, "out of memory\n");
-        	exit(1);
+		fprintf(stderr, "out of memory\n");
+		exit(1);
 	};
 
 	T("device-names", "parse various device names", _test_device_names_good);


