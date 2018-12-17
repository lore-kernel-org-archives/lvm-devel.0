From: David Teigland <teigland@sourceware.org>
Date: Mon, 17 Dec 2018 11:06:12 -0500
Subject: master - unit test: use_lvmetad replaced by event_activation
Message-ID: <201812171606.wBHG6Cho022855@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f1d36f6a2b441fbf84e59f435bd5169459392b1
Commit:        1f1d36f6a2b441fbf84e59f435bd5169459392b1
Parent:        2076dda0b8e6a33eec92a8e6b4616f8ab5a9b495
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Dec 17 10:04:44 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Dec 17 10:04:44 2018 -0600

unit test: use_lvmetad replaced by event_activation

---
 test/unit/activation-generator_t.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/test/unit/activation-generator_t.c b/test/unit/activation-generator_t.c
index f02da05..ef4946d 100644
--- a/test/unit/activation-generator_t.c
+++ b/test/unit/activation-generator_t.c
@@ -110,7 +110,7 @@ static void _test_parse_bool(void *fixture)
 struct pl_test {
 	const char *input;
 	bool success;
-	bool use_lvmetad;
+	bool event_activation;
 	bool sysinit_needed;
 };
 
@@ -119,8 +119,8 @@ static void _test_parse_line(void *fixture)
 	static struct pl_test _tests[] = {
         	{"", false, false, false},
         	{"sldkjfs", false, false, false},
-        	{"use_lvmetad=1", true, true, true},
-        	{"use_lvmetad=0", true, false, true},
+        	{"event_activation=1", true, true, true},
+        	{"event_activation=0", true, false, true},
         	{"use_lvmpolld=1", true, false, false},
         	{"use_lvmpolld=0", true, false, true}
 	};
@@ -139,9 +139,9 @@ static void _test_parse_line(void *fixture)
 			if (!r)
         			test_fail("_parse_line('%s') failed", t->input);
 
-			//if (cfg.use_lvmetad != t->use_lvmetad)
-			//	test_fail("_parse_line('%s') -> use_lvmetad='%s'",
-			//		t->input, _bool(cfg.use_lvmetad));
+			//if (cfg.event_activation != t->event_activation)
+			//	test_fail("_parse_line('%s') -> event_activation='%s'",
+			//		t->input, _bool(cfg.event_activation));
 
                 	if (cfg.sysinit_needed != t->sysinit_needed)
                         	test_fail("_parse_line('%s') -> sysinit_needed='%s'",
@@ -170,7 +170,7 @@ static void _test_get_config_bad_exit(void *fixture)
 struct gc_test {
         const char *output;
         bool success;
-        bool use_lvmetad;
+        bool event_activation;
         bool sysinit_needed;
 };
 
@@ -199,9 +199,9 @@ static void _test_get_config(void *fixture)
 		{"", true, false, true},
 		{"lsdjkf\n\n\n", false, false, false},
 
-		{"use_lvmetad=0\nuse_lvmpolld=1\n", true, false, false},
-		{"use_lvmetad=1\nuse_lvmpolld=1\n", true, true, false},
-		{"use_lvmetad=1\nuse_lvmpolld=0\n", true, true, true},
+		{"event_activation=0\nuse_lvmpolld=1\n", true, false, false},
+		{"event_activation=1\nuse_lvmpolld=1\n", true, true, false},
+		{"event_activation=1\nuse_lvmpolld=0\n", true, true, true},
 	};
 
 	bool r;
@@ -223,9 +223,9 @@ static void _test_get_config(void *fixture)
 			if (!r)
         			test_fail("_get_config() <- '%s' failed", t->output);
 
-			//if (t->use_lvmetad != cfg.use_lvmetad)
-			//	test_fail("_get_config() <- '%s', use_lvmetad = %s",
-			//		  t->output, _bool(cfg.use_lvmetad));
+			//if (t->event_activation != cfg.event_activation)
+			//	test_fail("_get_config() <- '%s', event_activation = %s",
+			//		  t->output, _bool(cfg.event_activation));
 
                 	if (t->sysinit_needed != cfg.sysinit_needed)
                         	test_fail("_get_config() <- '%s', sysinit = %s",


