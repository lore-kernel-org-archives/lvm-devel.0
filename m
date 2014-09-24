From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:33 +0000 (UTC)
Subject: master - debug: show stacktrace on error path
Message-ID: <20140924085733.D87C160E42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=edb3902c25801117557852f4a37802144da63841
Commit:        edb3902c25801117557852f4a37802144da63841
Parent:        2bfd986ea343244d33181c6b78dc39c8725014cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 22 15:59:50 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

debug: show stacktrace on error path

---
 tools/lvconvert.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index cc874c5..1d60c21 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3307,7 +3307,8 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 	}
 
 	lp->lv_to_poll = refreshed_lv;
-	ret = _lvconvert_single(cmd, refreshed_lv, lp);
+	if ((ret = _lvconvert_single(cmd, refreshed_lv, lp)) != ECMD_PROCESSED)
+		stack;
 
 	if (ret == ECMD_PROCESSED && lp->need_polling) {
 		/*
@@ -3316,8 +3317,9 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 		 */
 		unlock_vg(cmd, vg_name);
 
-		ret = _poll_logical_volume(cmd, lp->lv_to_poll,
-					  lp->wait_completion);
+		if (!(ret = _poll_logical_volume(cmd, lp->lv_to_poll,
+						 lp->wait_completion)) != ECMD_PROCESSED)
+			stack;
 
 		/* use LCK_VG_WRITE to match lvconvert()'s READ_FOR_UPDATE */
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {


