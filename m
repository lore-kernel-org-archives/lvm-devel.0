From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 15:50:40 -0400
Subject: master - indent: properly indent goto
Message-ID: <201706091950.v59JoeIu010297@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=305513178474d15adcba4785871c3f0321576fbe
Commit:        305513178474d15adcba4785871c3f0321576fbe
Parent:        57379157f4209acc72e943e26209b084575f811c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 14:52:40 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 21:49:19 2017 +0200

indent: properly indent goto

---
 tools/reporter.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 912d3ab..b9c4153 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -240,7 +240,7 @@ static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 
 	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
 			   seg->lv->vg, seg->lv, NULL, seg, NULL, &status, NULL))
-	goto_out;
+		goto_out;
 
 	r = ECMD_PROCESSED;
 out:


