From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Nov 2014 10:51:53 +0000 (UTC)
Subject: master - coverity: remove dead code in lv_info_with_seg_status
Message-ID: <20141126105153.9C17F60E2F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86ae68a5f7e396a6584b8003667b44a433d914fd
Commit:        86ae68a5f7e396a6584b8003667b44a433d914fd
Parent:        2cd98b27825b00459bd8e2c0539ffe5c09ed5b62
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 26 11:30:01 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 26 11:30:01 2014 +0100

coverity: remove dead code in lv_info_with_seg_status

Just call return 0 directly on error path, without using
"goto" - the code is short, no need to use it this way
(the dead code appeared as part of further changes in this
function).
---
 lib/activate/activate.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 60dba1b..258873b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -719,15 +719,13 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 			   struct lvinfo *lvinfo, struct lv_seg_status *lv_seg_status,
 			   int with_open_count, int with_read_ahead)
 {
-	int r = 0;
-
 	if (!activation())
 		return 0;
 
 	if (lv == lv_seg->lv) {
 		r = _lv_info(cmd, lv, use_layer, lvinfo, lv_seg, lv_seg_status,
 			     with_open_count, with_read_ahead);
-		goto out;
+		return 0;
 	}
 
 	/*
@@ -737,10 +735,6 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 	 */
 	return _lv_info(cmd, lv, use_layer, lvinfo, NULL, NULL, with_open_count, with_read_ahead) &&
 	       _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, lv_seg_status, 0, 0);
-
-	r = 1;
-out:
-	return r;
 }
 
 #define OPEN_COUNT_CHECK_RETRIES 25


