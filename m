From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Nov 2014 10:58:38 +0000 (UTC)
Subject: master - coverity: remove dead code in lv_info_with_seg_status (continued)
Message-ID: <20141126105838.9171A602C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8890e3ac1adcb9129c30d3fe9a1a11ceedebce4
Commit:        c8890e3ac1adcb9129c30d3fe9a1a11ceedebce4
Parent:        193f9b26a0a87b2f5ce9a308ea0d957fadfe4aeb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 26 11:58:25 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 26 11:58:25 2014 +0100

coverity: remove dead code in lv_info_with_seg_status (continued)

---
 lib/activate/activate.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 258873b..dd0a4f9 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -722,11 +722,9 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 	if (!activation())
 		return 0;
 
-	if (lv == lv_seg->lv) {
-		r = _lv_info(cmd, lv, use_layer, lvinfo, lv_seg, lv_seg_status,
-			     with_open_count, with_read_ahead);
-		return 0;
-	}
+	if (lv == lv_seg->lv)
+		return _lv_info(cmd, lv, use_layer, lvinfo, lv_seg, lv_seg_status,
+				with_open_count, with_read_ahead);
 
 	/*
 	 * If the info is requested for an LV and segment


