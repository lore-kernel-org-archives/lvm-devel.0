From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 30 Jan 2015 15:25:24 +0000 (UTC)
Subject: master - thin: fix upgrade regression
Message-ID: <20150130152524.DDA4260553@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40102ae01401741e007066373e8013f16c694f89
Commit:        40102ae01401741e007066373e8013f16c694f89
Parent:        a29a3ed3c37f72fc517ff6045b6105611abc1383
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 30 16:22:11 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 30 16:22:11 2015 +0100

thin: fix upgrade regression

Older lvm2 tools where always providing linear mapping for thin pool.
Recent lvm2 version however support external usage of thin pool and
empty/unused pools are loaded without such external linear mapping.

So this patch covers 'upgrade' problem, where older tool has activated
thin-pool with 'linear' layer mapping, and newer tools didn't expected
such mapping to exist and were not able to deactivate such table.

So before checking for new layout in dm-table, check if there is not
an old one already there.
---
 lib/activate/activate.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index dbfb427..c054531 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -655,8 +655,13 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 	}
 
 	/* New thin-pool has no layer, but -tpool suffix needs to be queried */
-	if (!use_layer && lv_is_new_thin_pool(lv))
-		use_layer = 1;
+	if (!use_layer && lv_is_new_thin_pool(lv)) {
+		/* Check if there isn't existing old thin pool mapping in the table */
+		if (!dev_manager_info(cmd->mem, lv, NULL, 0, 0, &dminfo, NULL, NULL))
+			return_0;
+		if (!dminfo.exists)
+			use_layer = 1;
+	}
 
 	if (seg_status)
 		seg_status->seg = seg;


