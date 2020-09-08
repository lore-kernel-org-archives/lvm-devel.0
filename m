From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Sep 2020 22:59:30 +0000 (GMT)
Subject: master - Revert "raid: do not enforce flushing of raids when it is not required"
Message-ID: <20200908225930.1E0EA384BC14@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8ea1817abccbd6acba83fb1ceb075830e747279
Commit:        a8ea1817abccbd6acba83fb1ceb075830e747279
Parent:        bb62af5b3db82e6558afd564acd3bcc0f2b94b50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 9 00:58:32 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 9 00:58:32 2020 +0200

Revert "raid: do not enforce flushing of raids when it is not required"

This reverts commit ce5ea07411d57a2bd276d8d29e46ce30b957f657.
More thinking needed.
---
 WHATS_NEW               | 1 -
 lib/activate/activate.c | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0aa23046d..aa3960b31 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,5 @@
 Version 2.03.11 - 
 ==================================
-  Allow raid extension without flushing raid LV first.
   Use _rmeta and _rimage as origin only devices for table loading.
   Switch code base to use flexible array syntax.
   Fix 64bit math when calculation cachevol size.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c5adc5065..0c6bd1a9a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2177,7 +2177,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	 * TODO: Relax this limiting condition further */
 	if (!flush_required &&
 	    (lv_is_pvmove(lv) || pvmove_lv ||
-	     (!lv_is_raid(lv) && !lv_is_mirror(lv) && !lv_is_thin_pool(lv) && !lv_is_thin_volume(lv)))) {
+	     (!lv_is_mirror(lv) && !lv_is_thin_pool(lv) && !lv_is_thin_volume(lv)))) {
 		log_debug("Requiring flush for LV %s.", display_lvname(lv));
 		flush_required = 1;
 	}


