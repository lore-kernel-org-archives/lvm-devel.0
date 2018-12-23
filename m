From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Dec 2018 19:12:52 -0500
Subject: master - tests: fix unit test
Message-ID: <201812230012.wBN0CqOT005392@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d8356d2084e0cc41ccc70db80e364bce10f0280
Commit:        6d8356d2084e0cc41ccc70db80e364bce10f0280
Parent:        1dee4b4ffcbc4324316718edbe464bbeb98a17db
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 23 00:54:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 23 01:07:27 2018 +0100

tests: fix unit test

Use more universal  /usr/bin/env bash
(as older systems do only have /bin/sh)
Uncommment disabled event_activation testing.
---
 test/unit/activation-generator_t.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/test/unit/activation-generator_t.c b/test/unit/activation-generator_t.c
index 6aa115c..8157c0c 100644
--- a/test/unit/activation-generator_t.c
+++ b/test/unit/activation-generator_t.c
@@ -137,9 +137,9 @@ static void _test_parse_line(void *fixture)
 			if (!r)
         			test_fail("_parse_line('%s') failed", t->input);
 
-			//if (cfg.event_activation != t->event_activation)
-			//	test_fail("_parse_line('%s') -> event_activation='%s'",
-			//		t->input, _bool(cfg.event_activation));
+			if (cfg.event_activation != t->event_activation)
+				test_fail("_parse_line('%s') -> event_activation='%s'",
+					t->input, _bool(cfg.event_activation));
 
                 	if (cfg.sysinit_needed != t->sysinit_needed)
                         	test_fail("_parse_line('%s') -> sysinit_needed='%s'",
@@ -180,7 +180,7 @@ static const char *_fake_lvmconfig(const char *output)
 	if (!fp)
         	return NULL;
 
-	fprintf(fp, "#!/usr/bin/sh\n");
+	fprintf(fp, "#!/usr/bin/env bash\n");
 	fprintf(fp, "cat <<EOF\n");
 	fprintf(fp, "%s", output);
 	fprintf(fp, "EOF\n");
@@ -221,9 +221,9 @@ static void _test_get_config(void *fixture)
 			if (!r)
         			test_fail("_get_config() <- '%s' failed", t->output);
 
-			//if (t->event_activation != cfg.event_activation)
-			//	test_fail("_get_config() <- '%s', event_activation = %s",
-			//		  t->output, _bool(cfg.event_activation));
+			if (t->event_activation != cfg.event_activation)
+				test_fail("_get_config() <- '%s', event_activation = %s",
+					  t->output, _bool(cfg.event_activation));
 
                 	if (t->sysinit_needed != cfg.sysinit_needed)
                         	test_fail("_get_config() <- '%s', sysinit = %s",


