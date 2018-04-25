From: David Teigland <teigland@sourceware.org>
Date: Wed, 25 Apr 2018 17:51:19 -0400
Subject: master - scan: don't use cmd mem pool in scan
Message-ID: <201804252151.w3PLpJjW017997@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0fe4f65f65faf9c61017bb14e281108b41165185
Commit:        0fe4f65f65faf9c61017bb14e281108b41165185
Parent:        4670e9f698099bf1b9612d16855f9207c0e0f467
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 25 15:48:19 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 25 16:40:08 2018 -0500

scan: don't use cmd mem pool in scan

Make it consistent with all the other allocations
in scanning.
---
 lib/label/label.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 4b18f56..97e2a0b 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -639,7 +639,7 @@ int label_scan(struct cmd_context *cmd)
 	}
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+		if (!(devl = dm_zalloc(sizeof(*devl))))
 			return 0;
 		devl->dev = dev;
 		dm_list_add(&all_devs, &devl->list);


