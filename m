From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Dec 2018 19:12:59 -0500
Subject: master - tests: indent
Message-ID: <201812230012.wBN0Cx8L005408@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee9d623d387c8789fc40e957af7b47d287a57368
Commit:        ee9d623d387c8789fc40e957af7b47d287a57368
Parent:        6d8356d2084e0cc41ccc70db80e364bce10f0280
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 23 00:55:00 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 23 01:07:27 2018 +0100

tests: indent

---
 test/unit/activation-generator_t.c |  114 ++++++++++++++++++------------------
 1 files changed, 57 insertions(+), 57 deletions(-)

diff --git a/test/unit/activation-generator_t.c b/test/unit/activation-generator_t.c
index 8157c0c..75f8ae4 100644
--- a/test/unit/activation-generator_t.c
+++ b/test/unit/activation-generator_t.c
@@ -42,22 +42,22 @@ static void _test_begins_with(void *fixture)
 		{"foo", "foobar", NULL},
 		{"fish", "fish", ""},
 		{"foo=bar ", "foo=", "bar "},
-        };
+	};
 
 	unsigned i;
 	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
-        	const char *val;
-        	struct bw_test *t = _tests + i;
-        	if (t->val) {
-                	if (!_begins_with(t->input, t->prefix, &val))
-                        	test_fail("_begins_with('%s', '%s') failed", t->input, t->prefix);
+		const char *val;
+		struct bw_test *t = _tests + i;
+		if (t->val) {
+			if (!_begins_with(t->input, t->prefix, &val))
+				test_fail("_begins_with('%s', '%s') failed", t->input, t->prefix);
 			if (strcmp(val, t->val))
-        			test_fail("_begins_with('%s', '%s') -> '%s', expected '%s'",
-                                          t->input, t->prefix, val, t->val);
+				test_fail("_begins_with('%s', '%s') -> '%s', expected '%s'",
+					  t->input, t->prefix, val, t->val);
 		} else {
 			if (_begins_with(t->input, t->prefix, &val))
-        			test_fail("_begins_with('%s', '%s') unexpectedly succeeded",
-                                          t->input, t->prefix);
+				test_fail("_begins_with('%s', '%s') unexpectedly succeeded",
+					  t->input, t->prefix);
 
 		}
 	}
@@ -71,7 +71,7 @@ struct pb_test {
 
 static const char *_bool(bool v)
 {
-        return v ? "true" : "false";
+	return v ? "true" : "false";
 }
 
 static void _test_parse_bool(void *fixture)
@@ -90,18 +90,18 @@ static void _test_parse_bool(void *fixture)
 	unsigned i;
 
 	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
-        	bool result;
-        	struct pb_test *t = _tests + i;
+		bool result;
+		struct pb_test *t = _tests + i;
 
-        	if (t->parsed) {
+		if (t->parsed) {
 			if (!_parse_bool(t->input, &result))
-        			test_fail("_parse_bool('%s') unexpectedly failed", t->input);
-        		if (result != t->result)
-                		test_fail("_parse_bool('%s') -> %s", t->input, _bool(result));
-        	} else {
-                	if (_parse_bool(t->input, &result))
-                        	test_fail("_parse_bool('%s') unexpectedly succeeded", t->input);
-        	}
+				test_fail("_parse_bool('%s') unexpectedly failed", t->input);
+			if (result != t->result)
+				test_fail("_parse_bool('%s') -> %s", t->input, _bool(result));
+		} else {
+			if (_parse_bool(t->input, &result))
+				test_fail("_parse_bool('%s') unexpectedly succeeded", t->input);
+		}
 	}
 }
 
@@ -115,18 +115,18 @@ struct pl_test {
 static void _test_parse_line(void *fixture)
 {
 	static struct pl_test _tests[] = {
-        	{"", false, false, false},
-        	{"sldkjfs", false, false, false},
-        	{"event_activation=1", true, true, true},
-        	{"event_activation=0", true, false, true},
-        	{"use_lvmpolld=1", true, false, false},
-        	{"use_lvmpolld=0", true, false, true}
+		{"", false, false, false},
+		{"sldkjfs", false, false, false},
+		{"event_activation=1", true, true, true},
+		{"event_activation=0", true, false, true},
+		{"use_lvmpolld=1", true, false, false},
+		{"use_lvmpolld=0", true, false, true}
 	};
 
 	unsigned i;
 
 	for (i = 0; i< DM_ARRAY_SIZE(_tests); i++) {
-        	bool r;
+		bool r;
 		struct config cfg = {
 			.sysinit_needed = true
 		};
@@ -135,50 +135,50 @@ static void _test_parse_line(void *fixture)
 		r = _parse_line(t->input, &cfg);
 		if (t->success) {
 			if (!r)
-        			test_fail("_parse_line('%s') failed", t->input);
+				test_fail("_parse_line('%s') failed", t->input);
 
 			if (cfg.event_activation != t->event_activation)
 				test_fail("_parse_line('%s') -> event_activation='%s'",
 					t->input, _bool(cfg.event_activation));
 
-                	if (cfg.sysinit_needed != t->sysinit_needed)
-                        	test_fail("_parse_line('%s') -> sysinit_needed='%s'",
-                                          t->input, _bool(cfg.sysinit_needed));
+			if (cfg.sysinit_needed != t->sysinit_needed)
+				test_fail("_parse_line('%s') -> sysinit_needed='%s'",
+					  t->input, _bool(cfg.sysinit_needed));
 		} else if (r)
-                		test_fail("_parse_line('%s') succeeded", t->input);
+				test_fail("_parse_line('%s') succeeded", t->input);
 	}
 }
 
 static void _test_get_config_bad_path(void *fixture)
 {
-        struct config cfg;
+	struct config cfg;
 
 	if (_get_config(&cfg, "/usr/bin/no-such-file"))
-        	test_fail("_get_config() succeeded despite a bad lvmconfig path");
+		test_fail("_get_config() succeeded despite a bad lvmconfig path");
 }
 
 static void _test_get_config_bad_exit(void *fixture)
 {
-        struct config cfg;
+	struct config cfg;
 
 	if (_get_config(&cfg, "/usr/bin/false"))
-        	test_fail("_get_config() succeeded despite a bad lvmconfig exit");
+		test_fail("_get_config() succeeded despite a bad lvmconfig exit");
 }
 
 struct gc_test {
-        const char *output;
-        bool success;
-        bool event_activation;
-        bool sysinit_needed;
+	const char *output;
+	bool success;
+	bool event_activation;
+	bool sysinit_needed;
 };
 
 static const char *_fake_lvmconfig(const char *output)
 {
-        const char *path = "./fake-lvmconfig";
+	const char *path = "./fake-lvmconfig";
 
 	FILE *fp = fopen(path, "w");
 	if (!fp)
-        	return NULL;
+		return NULL;
 
 	fprintf(fp, "#!/usr/bin/env bash\n");
 	fprintf(fp, "cat <<EOF\n");
@@ -207,33 +207,33 @@ static void _test_get_config(void *fixture)
 	const char *path;
 
 	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
-        	struct gc_test *t = _tests + i;
+		struct gc_test *t = _tests + i;
 		struct config cfg = {
 			.sysinit_needed = true
 		};
 
 		path = _fake_lvmconfig(t->output);
 		if (!path)
-        		test_fail("couldn't create fake lvmconfig");
+			test_fail("couldn't create fake lvmconfig");
 
-        	r = _get_config(&cfg, path);
-        	if (t->success) {
+		r = _get_config(&cfg, path);
+		if (t->success) {
 			if (!r)
-        			test_fail("_get_config() <- '%s' failed", t->output);
+				test_fail("_get_config() <- '%s' failed", t->output);
 
 			if (t->event_activation != cfg.event_activation)
 				test_fail("_get_config() <- '%s', event_activation = %s",
 					  t->output, _bool(cfg.event_activation));
 
-                	if (t->sysinit_needed != cfg.sysinit_needed)
-                        	test_fail("_get_config() <- '%s', sysinit = %s",
-                                          t->output, _bool(cfg.sysinit_needed));
-        	} else {
+			if (t->sysinit_needed != cfg.sysinit_needed)
+				test_fail("_get_config() <- '%s', sysinit = %s",
+					  t->output, _bool(cfg.sysinit_needed));
+		} else {
 			if (r)
-        			test_fail("_get_config() <- '%s' unexpectedly succeeded", t->output);
-        	}
+				test_fail("_get_config() <- '%s' unexpectedly succeeded", t->output);
+		}
 
-        	unlink(path);
+		unlink(path);
 	}
 }
 
@@ -245,8 +245,8 @@ static struct test_suite *_tests(void)
 {
 	struct test_suite *ts = test_suite_create(NULL, NULL);
 	if (!ts) {
-        	fprintf(stderr, "out of memory\n");
-        	exit(1);
+		fprintf(stderr, "out of memory\n");
+		exit(1);
 	};
 
 	T("begins-with", "Test cases for _begins_with()", _test_begins_with);


