From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:42 -0500
Subject: master - hints: validate sscanf results
Message-ID: <90372.119111412074001215@us-mta-16.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=219fe7235922cdcd559138def0a46a48ceaf528e
Commit:        219fe7235922cdcd559138def0a46a48ceaf528e
Parent:        d4d82dbb706da711cad73f045be7932ce1b23407
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:59:17 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

hints: validate sscanf results

---
 lib/label/hints.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index ec43dd3..09f12de 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -716,10 +716,9 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 		keylen = strlen("scan_lvs:");
 		if (!strncmp(_hint_line, "scan_lvs:", keylen)) {
 			int scan_lvs = 0;
-			sscanf(_hint_line + keylen, "%u", &scan_lvs);
-
-			if (scan_lvs != cmd->scan_lvs) {
-				log_debug("ignore hints with different scan_lvs");
+			if ((sscanf(_hint_line + keylen, "%u", &scan_lvs) != 1) ||
+			    scan_lvs != cmd->scan_lvs) {
+				log_debug("ignore hints with different or unreadable scan_lvs");
 				*needs_refresh = 1;
 				break;
 			}
@@ -728,7 +727,11 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 
 		keylen = strlen("devs_hash:");
 		if (!strncmp(_hint_line, "devs_hash:", keylen)) {
-			sscanf(_hint_line + keylen, "%u %u", &read_hash, &read_count);
+			if (sscanf(_hint_line + keylen, "%u %u", &read_hash, &read_count) != 2) {
+				log_debug("ignore hints with invalid devs_hash");
+				*needs_refresh = 1;
+				break;
+			}
 			continue;
 		}
 



