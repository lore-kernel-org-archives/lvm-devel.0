From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Aug 2022 11:34:14 +0000 (GMT)
Subject: main - vdo: fix --vdosettings parser
Message-ID: <20220815113414.6161B3858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bba96e8680ef7fa567d6361c269c0bfc05ce3d2c
Commit:        bba96e8680ef7fa567d6361c269c0bfc05ce3d2c
Parent:        fc5bc5985d03aef5846cb98882d17815fc00ca15
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 15 13:14:03 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 15 13:32:55 2022 +0200

vdo: fix --vdosettings parser

Parser was incorrectly parsing vdo_use_features - move the skip
of 'use_' prefix into internal loop which handles skipping of '_'.
---
 tools/toollib.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index c29ba2ab4..91eda84dd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1206,13 +1206,11 @@ out:
  */
 static int _compare_vdo_option(const char *b1, const char *b2)
 {
+	int use_skipped = 0;
+
 	if (strncasecmp(b1, "vdo", 3) == 0) // skip vdo prefix
 		b1 += 3;
 
-	if ((tolower(*b1) != tolower(*b2)) &&
-	    (strncmp(b2, "use_", 4) == 0))
-		b2 += 4;  // try again with skipped prefix 'use_'
-
 	while (*b1 && *b2) {
 		if (tolower(*b1) == tolower(*b2)) {
 			++b1;
@@ -1224,8 +1222,14 @@ static int _compare_vdo_option(const char *b1, const char *b2)
 			++b1;           // skip to next char
 		else if (*b2 == '_')
 			++b2;           // skip to next char
-		else
+		else {
+			if (!use_skipped++ && (strncmp(b2, "use_", 4) == 0)) {
+				b2 += 4;  // try again with skipped prefix 'use_'
+				continue;
+			}
+
 			break;          // mismatch
+		}
 	}
 
 	return (*b1 || *b2) ? 0 : 1;

