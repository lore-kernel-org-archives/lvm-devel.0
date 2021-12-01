From: David Teigland <teigland@sourceware.org>
Date: Wed,  1 Dec 2021 19:42:48 +0000 (GMT)
Subject: main - pvscan: fix filter symlink checks
Message-ID: <20211201194248.012C7385840C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05d9a013516f23e27b04b6933705c6ae45f9f5b2
Commit:        05d9a013516f23e27b04b6933705c6ae45f9f5b2
Parent:        d5402e55f6b9d3a5f407502ce5c7a8a5bfd12243
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 1 13:40:09 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 1 13:42:32 2021 -0600

pvscan: fix filter symlink checks

Fixes commit "pvscan: match device arg to filter symlink"
which failed to account for the fact that filter entries
are not just path names but include "a" or "r", etc.
---
 tools/pvscan.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 429b5e676..dcf183a46 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -828,6 +828,7 @@ static int _filter_uses_symlinks(struct cmd_context *cmd, int filter_cfg)
 {
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
+	const char *fname;
 
 	if ((cn = find_config_tree_array(cmd, filter_cfg, NULL))) {
         	for (cv = cn->v; cv; cv = cv->next) {
@@ -836,19 +837,22 @@ static int _filter_uses_symlinks(struct cmd_context *cmd, int filter_cfg)
 			if (!cv->v.str)
 				continue;
 
-			if (!strncmp(cv->v.str, "/dev/disk/", 10))
+			fname = cv->v.str;
+
+			if (fname[0] != 'a')
+				continue;
+
+			if (strstr(fname, "/dev/disk/"))
 				return 1;
-			if (!strncmp(cv->v.str, "/dev/mapper/", 12))
+			if (strstr(fname, "/dev/mapper/"))
 				return 1;
-			if (cv->v.str[0] == '/')
-				continue;
 
 			/* In case /dev/disk/by was omitted */
-			if (strstr(cv->v.str, "lvm-pv-uuid"))
+			if (strstr(fname, "lvm-pv-uuid"))
 				return 1;
-			if (strstr(cv->v.str, "dm-uuid"))
+			if (strstr(fname, "dm-uuid"))
 				return 1;
-			if (strstr(cv->v.str, "wwn-"))
+			if (strstr(fname, "wwn-"))
 				return 1;
 		}
 	}


