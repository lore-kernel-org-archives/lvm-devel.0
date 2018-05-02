From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 2 May 2018 08:32:46 -0400
Subject: master - unit-test/matcher_t: add another (failing!) test for Kabi
Message-ID: <201805021232.w42CWkRR012192@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=506ab29bfd8ec5721cdabb0745ae29af739b47a4
Commit:        506ab29bfd8ec5721cdabb0745ae29af739b47a4
Parent:        11436b00e0fa4a54ce504beba72b23bbf0682b27
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 2 13:31:57 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 2 13:31:57 2018 +0100

unit-test/matcher_t: add another (failing!) test for Kabi

---
 test/unit/matcher_t.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/test/unit/matcher_t.c b/test/unit/matcher_t.c
index a5eb5f9..b5bf1cf 100644
--- a/test/unit/matcher_t.c
+++ b/test/unit/matcher_t.c
@@ -72,6 +72,43 @@ static void test_matching(void *fixture)
 		T_ASSERT_EQUAL(dm_regex_match(scanner, nonprint[i].str), nonprint[i].expected - 1);
 }
 
+static void test_kabi_query(void *fixture)
+{
+        static const char *_patterns[] = {
+                "loop", "/dev/md.*", ".*"
+        };
+
+        static struct {
+                const char *input;
+                int r;
+        } _cases[] = {
+		{"foo", 2},
+		{"/dev/mapper/vg-lvol1", 2},
+		{"/dev/mapper/vglvol1", 2},
+		{"loop", 0},
+        };
+
+	int r;
+	unsigned i;
+	struct dm_pool *mem = fixture;
+  	struct dm_regex *scanner;
+
+	scanner = dm_regex_create(mem, _patterns, DM_ARRAY_SIZE(_patterns));
+	T_ASSERT(scanner != NULL);
+
+	for (i = 0; i < DM_ARRAY_SIZE(_cases); i++) {
+        	r = dm_regex_match(scanner, _cases[i].input);
+        	if (r != _cases[i].r) {
+                	test_fail("'%s' expected to match '%s', but matched %s",
+                                  _cases[i].input,
+                                  _cases[i].r >= DM_ARRAY_SIZE(_patterns) ? "<nothing>" : _patterns[_cases[i].r],
+                                  r >= DM_ARRAY_SIZE(_patterns) ? "<nothing>" : _patterns[r]);
+        	}
+	}
+
+
+}
+
 #define T(path, desc, fn) register_test(ts, "/base/regex/" path, desc, fn)
 
 void regex_tests(struct dm_list *all_tests)
@@ -84,6 +121,7 @@ void regex_tests(struct dm_list *all_tests)
 
 	T("fingerprints", "not sure", test_fingerprints);
 	T("matching", "test the matcher with a variety of regexes", test_matching);
+	T("kabi-query", "test the matcher with some specific patterns", test_kabi_query);
 
 	dm_list_add(all_tests, &ts->list);
 }


