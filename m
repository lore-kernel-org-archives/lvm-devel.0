From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:56:12 +0000 (UTC)
Subject: master - lvremove: Revert to allowing removal of partial LVs.
Message-ID: <20120926175612.C93E7A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3124840185f9dc3e842c812e490a6f61ae040a2b
Commit:        3124840185f9dc3e842c812e490a6f61ae040a2b
Parent:        5f5832e318e43c86054a28a4c9f3003542513663
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 26 12:25:45 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

lvremove: Revert to allowing removal of partial LVs.

---
 tools/lvremove.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/tools/lvremove.c b/tools/lvremove.c
index 2c5b317..0252149 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -26,12 +26,6 @@ static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
         if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
                 lv = origin;
 
-	if (lv->status & PARTIAL_LV) {
-		log_error("Not removing LV %s/%s because part or all of it is missing.",
-			  lv->vg->name, lv->name);
-		return ECMD_FAILED;
-	}
-
 	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG), 0)) {
 		stack;
 		return ECMD_FAILED;


