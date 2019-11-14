From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:08:16 -0500
Subject: master - hints: no need to check for NULL before free
Message-ID: <42156.119111412081302520@us-mta-425.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1760b96368ae41e76e89a7064254f995713a41e5
Commit:        1760b96368ae41e76e89a7064254f995713a41e5
Parent:        9af1d63b4d96facb0aa055a44c2f61eac01e13f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:17:09 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

hints: no need to check for NULL before free

free() itself checks for NULL.
---
 lib/label/hints.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index c6039d5..ac2c089 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -688,13 +688,11 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 			_filter_to_str(cmd, devices_global_filter_CFG, &filter_str);
 			if (!filter_str || strcmp(filter_str, _hint_line + keylen)) {
 				log_debug("ignore hints with different global_filter");
-				if (filter_str)
-					free(filter_str);
+				free(filter_str);
 				*needs_refresh = 1;
 				break;
 			}
-			if (filter_str)
-				free(filter_str);
+			free(filter_str);
 			continue;
 		}
 
@@ -703,13 +701,11 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 			_filter_to_str(cmd, devices_filter_CFG, &filter_str);
 			if (!filter_str || strcmp(filter_str, _hint_line + keylen)) {
 				log_debug("ignore hints with different filter");
-				if (filter_str)
-					free(filter_str);
+				free(filter_str);
 				*needs_refresh = 1;
 				break;
 			}
-			if (filter_str)
-				free(filter_str);
+			free(filter_str);
 			continue;
 		}
 
@@ -907,13 +903,11 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 
 	_filter_to_str(cmd, devices_global_filter_CFG, &filter_str);
 	fprintf(fp, "global_filter:%s\n", filter_str ?: "-");
-	if (filter_str)
-		free(filter_str);
+	free(filter_str);
 
 	_filter_to_str(cmd, devices_filter_CFG, &filter_str);
 	fprintf(fp, "filter:%s\n", filter_str ?: "-");
-	if (filter_str)
-		free(filter_str);
+	free(filter_str);
 
 	fprintf(fp, "scan_lvs:%d\n", cmd->scan_lvs);
 



