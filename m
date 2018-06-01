From: David Teigland <teigland@sourceware.org>
Date: Fri, 1 Jun 2018 14:16:12 -0400
Subject: master - scan: clean exit for alloc failure
Message-ID: <201806011816.w51IGCnZ002060@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b5b1a9b6f03e9452c7a9d602247e61e808c316b
Commit:        7b5b1a9b6f03e9452c7a9d602247e61e808c316b
Parent:        0625c7f372a8481e21752b1fc930984ba7c900db
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 1 10:40:28 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 1 13:15:22 2018 -0500

scan: clean exit for alloc failure

---
 lib/label/label.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 427caa9..f36c706 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -832,7 +832,7 @@ int label_scan(struct cmd_context *cmd)
 
 	while ((dev = dev_iter_get(iter))) {
 		if (!(devl = dm_zalloc(sizeof(*devl))))
-			return 0;
+			continue;
 		devl->dev = dev;
 		dm_list_add(&all_devs, &devl->list);
 


