From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu,  8 Dec 2022 11:37:13 +0000 (GMT)
Subject: rhel-8.8.0 - vdo: fix --vdosettings parser
Message-ID: <20221208113713.2F6A63872205@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b56e8fc94d4d2b6d384148e3f74c54f4e1d816e6
Commit:        b56e8fc94d4d2b6d384148e3f74c54f4e1d816e6
Parent:        7db3a53d8a3aa7401337fb9aaf00f19cf4407e70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 15 13:14:03 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Dec 8 12:34:22 2022 +0100

vdo: fix --vdosettings parser

Parser was incorrectly parsing vdo_use_features - move the skip
of 'use_' prefix into internal loop which handles skipping of '_'.

(cherry picked from commit bba96e8680ef7fa567d6361c269c0bfc05ce3d2c)
---
 tools/toollib.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 210b3dca5..d9a1a92ec 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1198,13 +1198,11 @@ out:
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
@@ -1216,8 +1214,14 @@ static int _compare_vdo_option(const char *b1, const char *b2)
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

