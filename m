From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:13:23 -0500
Subject: master - tests: drop use_lvmetad from unit test
Message-ID: <201811292213.wATMDNr7016708@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=41afe8c5cc7cde890a031ccac1cff0bf9d72220d
Commit:        41afe8c5cc7cde890a031ccac1cff0bf9d72220d
Parent:        e940293c336b22e018aac96217e5e67b2397dde6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 29 22:52:46 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:10:09 2018 +0100

tests: drop use_lvmetad from unit test

---
 test/unit/activation-generator_t.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/test/unit/activation-generator_t.c b/test/unit/activation-generator_t.c
index cff0968..f02da05 100644
--- a/test/unit/activation-generator_t.c
+++ b/test/unit/activation-generator_t.c
@@ -129,20 +129,19 @@ static void _test_parse_line(void *fixture)
 
 	for (i = 0; i< DM_ARRAY_SIZE(_tests); i++) {
         	bool r;
-		struct config cfg;
+		struct config cfg = {
+			.sysinit_needed = true
+		};
 		struct pl_test *t = _tests + i;
 
-		cfg.use_lvmetad = false;
-		cfg.sysinit_needed = true;
-
 		r = _parse_line(t->input, &cfg);
 		if (t->success) {
 			if (!r)
         			test_fail("_parse_line('%s') failed", t->input);
 
-        		if (cfg.use_lvmetad != t->use_lvmetad)
-                		test_fail("_parse_line('%s') -> use_lvmetad='%s'",
-                                          t->input, _bool(cfg.use_lvmetad));
+			//if (cfg.use_lvmetad != t->use_lvmetad)
+			//	test_fail("_parse_line('%s') -> use_lvmetad='%s'",
+			//		t->input, _bool(cfg.use_lvmetad));
 
                 	if (cfg.sysinit_needed != t->sysinit_needed)
                         	test_fail("_parse_line('%s') -> sysinit_needed='%s'",
@@ -207,14 +206,13 @@ static void _test_get_config(void *fixture)
 
 	bool r;
 	unsigned i;
-	struct config cfg;
 	const char *path;
 
 	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
         	struct gc_test *t = _tests + i;
-
-        	cfg.use_lvmetad = false;
-        	cfg.sysinit_needed = true;
+		struct config cfg = {
+			.sysinit_needed = true
+		};
 
 		path = _fake_lvmconfig(t->output);
 		if (!path)
@@ -225,9 +223,9 @@ static void _test_get_config(void *fixture)
 			if (!r)
         			test_fail("_get_config() <- '%s' failed", t->output);
 
-        		if (t->use_lvmetad != cfg.use_lvmetad)
-                		test_fail("_get_config() <- '%s', use_lvmetad = %s",
-                                          t->output, _bool(cfg.use_lvmetad));
+			//if (t->use_lvmetad != cfg.use_lvmetad)
+			//	test_fail("_get_config() <- '%s', use_lvmetad = %s",
+			//		  t->output, _bool(cfg.use_lvmetad));
 
                 	if (t->sysinit_needed != cfg.sysinit_needed)
                         	test_fail("_get_config() <- '%s', sysinit = %s",


