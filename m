From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 2 May 2018 08:55:03 -0400
Subject: master - unit-test/matcher_t: Fixup Kabi's test
Message-ID: <201805021255.w42Ct3TD015431@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9fe0be871c916c1105212f916d8c6904d12ea5b4
Commit:        9fe0be871c916c1105212f916d8c6904d12ea5b4
Parent:        506ab29bfd8ec5721cdabb0745ae29af739b47a4
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 2 13:53:43 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 2 13:53:43 2018 +0100

unit-test/matcher_t: Fixup Kabi's test

The matcher matches the regexes in reverse order.
---
 test/unit/matcher_t.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/test/unit/matcher_t.c b/test/unit/matcher_t.c
index b5bf1cf..31109d2 100644
--- a/test/unit/matcher_t.c
+++ b/test/unit/matcher_t.c
@@ -74,18 +74,20 @@ static void test_matching(void *fixture)
 
 static void test_kabi_query(void *fixture)
 {
+        // Remember, matches regexes from last to first.
         static const char *_patterns[] = {
-                "loop", "/dev/md.*", ".*"
+                ".*", ".*/dev/md.*", "loop"
         };
 
         static struct {
                 const char *input;
                 int r;
         } _cases[] = {
-		{"foo", 2},
-		{"/dev/mapper/vg-lvol1", 2},
-		{"/dev/mapper/vglvol1", 2},
-		{"loop", 0},
+		{"foo", 0},
+		{"/dev/mapper/vg-lvol1", 0},
+		{"/dev/mapper/vglvol1", 0},
+		{"/dev/md1", 1},
+		{"loop", 2},
         };
 
 	int r;


