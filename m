From: David Teigland <teigland@sourceware.org>
Date: Thu, 14 Nov 2019 13:18:23 -0500
Subject: master - Revert "hints: rewrite function"
Message-ID: <03498.119111413181901667@us-mta-206.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ea71a9eb94a703975d8f59f941d02039def3be4
Commit:        7ea71a9eb94a703975d8f59f941d02039def3be4
Parent:        31a862a6be181764c3f505580916e11882b195a7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 14 12:15:05 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 14 12:15:05 2019 -0600

Revert "hints: rewrite function"

This reverts commit 70fb31b5d6863248b5adfb2581b706cbb158b30e.
---
 lib/label/hints.c |   39 ++++++++++++++++++++++++++-------------
 1 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 45ab2ff..f8e8f45 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -586,29 +586,42 @@ static void _filter_to_str(struct cmd_context *cmd, int filter_cfg, char **strp)
 	char *str;
 	int pos = 0;
 	int len = 0;
+	int ret;
 
 	*strp = NULL;
 
-	if (!(cn = find_config_tree_array(cmd, filter_cfg, NULL)))
+	if (!(cn = find_config_tree_array(cmd, filter_cfg, NULL))) {
 		/* shouldn't happen because default is a|*| */
 		return;
+	}
+
+	for (cv = cn->v; cv; cv = cv->next) {
+		if (cv->type != DM_CFG_STRING)
+			continue;
 
-	for (cv = cn->v; cv; cv = cv->next)
-		if (cv->type == DM_CFG_STRING)
-			len += strlen(cv->v.str) + 1;
+		len += (strlen(cv->v.str) + 1);
+	}
+	len++;
+
+	if (len == 1) {
+		/* shouldn't happen because default is a|*| */
+		return;
+	}
 
-	if (!len++ || !(str = malloc(len)))
+	if (!(str = malloc(len)))
 		return;
+	memset(str, 0, len);
 
-	for (cv = cn->v; cv; cv = cv->next)
-		if (cv->type == DM_CFG_STRING) {
-			len = strlen(cv->v.str);
-			memcpy(str + pos, cv->v.str, len);
-			pos += len;
-			str[pos++] = 0;
-		}
+	for (cv = cn->v; cv; cv = cv->next) {
+		if (cv->type != DM_CFG_STRING)
+			continue;
 
-	str[pos] = 0;
+		ret = snprintf(str + pos, len - pos, "%s", cv->v.str);
+
+		if (ret >= len - pos)
+			break;
+		pos += ret;
+	}
 
 	*strp = str;
 }



