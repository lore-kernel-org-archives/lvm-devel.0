From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:40 -0500
Subject: master - hints: allocate hint only when needed
Message-ID: <41536.119111412073700200@us-mta-368.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d4d82dbb706da711cad73f045be7932ce1b23407
Commit:        d4d82dbb706da711cad73f045be7932ce1b23407
Parent:        70fb31b5d6863248b5adfb2581b706cbb158b30e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:57:43 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

hints: allocate hint only when needed

Avoid mem leaking hint on every loop continue and
allocate hint only when it's going to be added into list.

Switch to use 'dm_strncpy()' and validate sizes.
---
 lib/label/hints.c |   30 ++++++++++++++++++------------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 79648b9..ec43dd3 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -625,7 +625,8 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	char devpath[PATH_MAX];
 	FILE *fp;
 	struct dev_iter *iter;
-	struct hint *hint;
+	struct hint hint;
+	struct hint *alloc_hint;
 	struct device *dev;
 	char *split[HINT_LINE_WORDS];
 	char *name, *pvid, *devn, *vgname, *p, *filter_str = NULL;
@@ -649,11 +650,7 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 		split[i] = NULL;
 
 	while (fgets(_hint_line, sizeof(_hint_line), fp)) {
-		if (!(hint = zalloc(sizeof(struct hint)))) {
-			ret = 0;
-			break;
-		}
-
+		memset(&hint, 0, sizeof(hint));
 		if (_hint_line[0] == '#')
 			continue;
 
@@ -751,19 +748,28 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 		vgname = split[3];
 
 		if (name && !strncmp(name, "scan:", 5))
-			strncpy(hint->name, name+5, PATH_MAX);
+			if (!dm_strncpy(hint.name, name + 5, sizeof(hint.name)))
+				continue;
 
 		if (pvid && !strncmp(pvid, "pvid:", 5))
-			strncpy(hint->pvid, pvid+5, ID_LEN);
+			if (!dm_strncpy(hint.pvid, pvid + 5, sizeof(hint.pvid)))
+				continue;
 
 		if (devn && sscanf(devn, "devn:%d:%d", &major, &minor) == 2)
-			hint->devt = makedev(major, minor);
+			hint.devt = makedev(major, minor);
 
 		if (vgname && (strlen(vgname) > 3) && (vgname[4] != '-'))
-			strncpy(hint->vgname, vgname+3, NAME_LEN);
+			if (!dm_strncpy(hint.vgname, vgname + 3, sizeof(hint.vgname)))
+				continue;
+
+		if (!(alloc_hint = malloc(sizeof(struct hint)))) {
+			ret = 0;
+			break;
+		}
+		memcpy(alloc_hint, &hint, sizeof(hint));
 
-		log_debug("add hint %s %s %d:%d %s", hint->name, hint->pvid, major, minor, vgname);
-		dm_list_add(hints, &hint->list);
+		log_debug("add hint %s %s %d:%d %s", hint.name, hint.pvid, major, minor, vgname);
+		dm_list_add(hints, &alloc_hint->list);
 		found++;
 	}
 



