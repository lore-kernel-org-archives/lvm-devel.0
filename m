From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:43 -0500
Subject: master - hints: rewrite function
Message-ID: <81539.119111412073300781@us-mta-72.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70fb31b5d6863248b5adfb2581b706cbb158b30e
Commit:        70fb31b5d6863248b5adfb2581b706cbb158b30e
Parent:        1f4968289c9c0e2a1e850317ef173df11938b7f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:15:18 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

hints: rewrite function

---
 lib/label/hints.c |   39 +++++++++++++--------------------------
 1 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 6510fcf..79648b9 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -586,42 +586,29 @@ static void _filter_to_str(struct cmd_context *cmd, int filter_cfg, char **strp)
 	char *str;
 	int pos = 0;
 	int len = 0;
-	int ret;
 
 	*strp = NULL;
 
-	if (!(cn = find_config_tree_array(cmd, filter_cfg, NULL))) {
+	if (!(cn = find_config_tree_array(cmd, filter_cfg, NULL)))
 		/* shouldn't happen because default is a|*| */
 		return;
-	}
-
-	for (cv = cn->v; cv; cv = cv->next) {
-		if (cv->type != DM_CFG_STRING)
-			continue;
 
-		len += (strlen(cv->v.str) + 1);
-	}
-	len++;
-
-	if (len == 1) {
-		/* shouldn't happen because default is a|*| */
-		return;
-	}
+	for (cv = cn->v; cv; cv = cv->next)
+		if (cv->type == DM_CFG_STRING)
+			len += strlen(cv->v.str) + 1;
 
-	if (!(str = malloc(len)))
+	if (!len++ || !(str = malloc(len)))
 		return;
-	memset(str, 0, len);
-
-	for (cv = cn->v; cv; cv = cv->next) {
-		if (cv->type != DM_CFG_STRING)
-			continue;
 
-		ret = snprintf(str + pos, len - pos, "%s", cv->v.str);
+	for (cv = cn->v; cv; cv = cv->next)
+		if (cv->type == DM_CFG_STRING) {
+			len = strlen(cv->v.str);
+			memcpy(str + pos, cv->v.str, len);
+			pos += len;
+			str[pos++] = 0;
+		}
 
-		if (ret >= len - pos)
-			break;
-		pos += ret;
-	}
+	str[pos] = 0;
 
 	*strp = str;
 }



