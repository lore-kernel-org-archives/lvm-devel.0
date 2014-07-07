From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  7 Jul 2014 14:29:18 +0000 (UTC)
Subject: master - report: addendum for previous commit
Message-ID: <20140707142918.4041760285@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e1c4a3818fa2af76b7b7890939c9e7ec9cb6818
Commit:        9e1c4a3818fa2af76b7b7890939c9e7ec9cb6818
Parent:        83b55c2dfba12db95fa5247039470278741372ab
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 7 16:28:13 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 7 16:28:13 2014 +0200

report: addendum for previous commit

Really call lv_info only if needed!
---
 tools/reporter.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 5e9fb24..0780283 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -91,7 +91,7 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
-	struct lvinfo lvinfo = {.exists = 0};
+	struct lvinfo lvinfo;
 
 	struct volume_group _free_vg = {
 		.cmd = cmd,
@@ -136,7 +136,8 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	dm_list_init(&_free_logical_volume.segs_using_this_lv);
 	dm_list_init(&_free_logical_volume.snapshot_segs);
 
-	if (seg && !lv_info(cmd, seg->lv, 0, &lvinfo, 1, 1)) {
+	lvinfo.exists = 0;
+	if (seg && lv_info_needed && !lv_info(cmd, seg->lv, 0, &lvinfo, 1, 1)) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}


