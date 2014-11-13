From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 13 Nov 2014 13:43:04 +0000 (UTC)
Subject: master - cleanup: free mempool memory used for LV status in PVSEGS reporting
Message-ID: <20141113134304.8E85460EBA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48874703d2deee676d326ed4447c7944ab728767
Commit:        48874703d2deee676d326ed4447c7944ab728767
Parent:        4de7699855e06bf341d5f91b9c3fc4ba4de18cd6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 13 14:41:01 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 13 14:41:01 2014 +0100

cleanup: free mempool memory used for LV status in PVSEGS reporting

Addendum to previous commit 4de7699855e06bf341d5f91b9c3fc4ba4de18cd6.
---
 tools/reporter.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index ec1feb2..24191f1 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -223,7 +223,8 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
 	struct lvinfo lvinfo = { .exists = 0 };
-	struct lv_seg_status lv_seg_status = { .type = SEG_STATUS_NONE };
+	struct lv_seg_status lv_seg_status = { .type = SEG_STATUS_NONE,
+					       .status = NULL };
 
 	struct segment_type _freeseg_type = {
 		.name = "free",
@@ -269,6 +270,8 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	}
 
  out:
+	if (seg && lv_seg_status.status)
+		dm_pool_free(lv_seg_status.mem, lv_seg_status.status);
 	return ret;
 }
 


