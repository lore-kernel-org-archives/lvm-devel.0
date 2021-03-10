From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:38 +0000 (GMT)
Subject: main - cov: fix iter memleak in vgimportclose
Message-ID: <20210310003638.CE4F2385802B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=241c63f7a72cecad085c8983b8a294d8d9985119
Commit:        241c63f7a72cecad085c8983b8a294d8d9985119
Parent:        131ca0eb9582dd183ed40400caf4fc832f43cb16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 01:25:37 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:29:06 2021 +0100

cov: fix iter memleak in vgimportclose

Add missing release of iterator on error path.
---
 tools/vgimportclone.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 58cae5fac..18f10f49a 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -190,6 +190,7 @@ static int _get_other_devs(struct cmd_context *cmd, struct dm_list *new_devs, st
 	struct dev_iter *iter;
 	struct device *dev;
 	struct device_list *devl;
+	int r = 1;
 
 	if (!(iter = dev_iter_create(cmd->filter, 0)))
 		return_0;
@@ -197,14 +198,16 @@ static int _get_other_devs(struct cmd_context *cmd, struct dm_list *new_devs, st
 	while ((dev = dev_iter_get(cmd, iter))) {
 		if (_get_device_list(new_devs, dev))
 			continue;
-		if (!(devl = malloc(sizeof(*devl))))
-			return_0;
+		if (!(devl = malloc(sizeof(*devl)))) {
+			r = 0;
+			goto_bad;
+		}
 		devl->dev = dev;
 		dm_list_add(other_devs, &devl->list);
 	}
-
+bad:
 	dev_iter_destroy(iter);
-	return 1;
+	return r;
 }
 
 int vgimportclone(struct cmd_context *cmd, int argc, char **argv)


