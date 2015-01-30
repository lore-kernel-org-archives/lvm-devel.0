From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 30 Jan 2015 14:59:51 +0000 (UTC)
Subject: master - thin: report proper status for thin pool
Message-ID: <20150130145951.4400260E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a29a3ed3c37f72fc517ff6045b6105611abc1383
Commit:        a29a3ed3c37f72fc517ff6045b6105611abc1383
Parent:        e8aab3a7fdb22655493ace8bac75e655b5b0cffe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 30 15:29:39 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 30 15:58:12 2015 +0100

thin: report proper status for thin pool

After commit 158e9988768be344c0c97acdf52d1c020ab8c83e where we may
start to readlv_attr with a 'shared' ioctl call for a single lvs line
we where obtaing single status for thin pools.
However this is not properly reflecting lvm2 reality.

Correcting this by reading lv status from layered thin pool, but lv info
from non-layered (linear) mapped device which is maintained for proper
cluster locking.
---
 tools/reporter.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 29d326c..7c481be 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -65,10 +65,14 @@ static int _do_info_and_status(struct cmd_context *cmd,
 			return_0;
 		if (!lv_seg)
 			_choose_lv_segment_for_status_report(lv, &lv_seg);
-		if (do_info)
+		if (do_info) {
 			/* both info and status */
 			status->info_ok = lv_info_with_seg_status(cmd, lv, lv_seg, use_layer, status, 1, 1);
-		else
+			/* for inactive thin-pools reset lv info struct */
+			if (use_layer && status->info_ok &&
+			    !lv_info(cmd, lv, 0, NULL, 0, 0))
+				memset(&status->info,  0, sizeof(status->info));
+		} else
 			/* status only */
 			status->info_ok = lv_status(cmd, lv_seg, use_layer, &status->seg_status);
 	} else if (do_info)


