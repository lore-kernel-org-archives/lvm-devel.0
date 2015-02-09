From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  9 Feb 2015 10:48:35 +0000 (UTC)
Subject: master - reporter: properly check for _do_info_and_status return value and free the mempool if created within the fn
Message-ID: <20150209104835.DCAA76022B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e4ea46cfee9afcfc9a48eb60925177890c5ec31
Commit:        4e4ea46cfee9afcfc9a48eb60925177890c5ec31
Parent:        4065741a672d97f1c6b158ad781bc486c38e7c0a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 9 11:48:21 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 9 11:48:21 2015 +0100

reporter: properly check for _do_info_and_status return value and free the mempool if created within the fn

---
 tools/reporter.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 7c481be..20fa4ab 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -92,10 +92,8 @@ static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 	};
 	int r = ECMD_FAILED;
 
-	if (!_do_info_and_status(cmd, lv, NULL, &status, do_info, do_status)) {
-		stack;
-		return r;
-	}
+	if (!_do_info_and_status(cmd, lv, NULL, &status, do_info, do_status))
+		goto_out;
 
 	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL,
 			   &status, NULL))
@@ -143,10 +141,8 @@ static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 	};
 	int r = ECMD_FAILED;
 
-	if (!_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status)) {
-		stack;
-		return r;
-	}
+	if (!_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status))
+		goto_out;
 
 	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL,
 			   &status, NULL))
@@ -268,8 +264,8 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 		.lv = &_free_logical_volume
 	};
 
-	if (seg)
-		_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status);
+	if (seg && !_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status))
+		goto_out;
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
 			   seg ? : &_free_lv_segment, pvseg, &status,


