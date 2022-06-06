From: David Teigland <teigland@sourceware.org>
Date: Mon,  6 Jun 2022 16:43:07 +0000 (GMT)
Subject: main - filter-mpath: handle other wwid types in blacklist
Message-ID: <20220606164307.D4E3D3857B9A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c302903dbab1d5fd05b344c654bed83c9ecb69f8
Commit:        c302903dbab1d5fd05b344c654bed83c9ecb69f8
Parent:        bfe072e4388b530cbf5369be8a8f1305220198bf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 6 11:39:02 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 6 11:39:02 2022 -0500

filter-mpath: handle other wwid types in blacklist

Fixes commit 494372b4eed0c8f6040e3357939eb7511ac25745
  "filter-mpath: use multipath blacklist"
to handle wwids with initial type digits 1 and 2 used
for t10 and eui ids.  Originally recognized type 3 naa.
---
 lib/device/dev-mpath.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
index 270366ad7..846f6c8ba 100644
--- a/lib/device/dev-mpath.c
+++ b/lib/device/dev-mpath.c
@@ -54,7 +54,7 @@ static void _read_blacklist_file(const char *path)
 	int section_black = 0;
 	int section_exceptions = 0;
 	int found_quote;
-	int found_three;
+	int found_type;
 	int i, j;
 
 	if (!(fp = fopen(path, "r")))
@@ -114,7 +114,7 @@ static void _read_blacklist_file(const char *path)
 
 		memset(wwid, 0, sizeof(wwid));
 		found_quote = 0;
-		found_three = 0;
+		found_type = 0;
 		j = 0;
 
 		for (; i < MAX_WWID_LINE; i++) {
@@ -132,9 +132,10 @@ static void _read_blacklist_file(const char *path)
 			/* second quote is end of wwid */
 			if ((line[i] == '"') && found_quote)
 				break;
-			/* ignore first "3" in wwid */
-			if ((line[i] == '3') && !found_three) {
-				found_three = 1;
+			/* exclude initial 3/2/1 for naa/eui/t10 */
+			if (!j && !found_type &&
+			    ((line[i] == '3') || (line[i] == '2') || (line[i] == '1'))) {
+				found_type = 1;
 				continue;
 			}
 

