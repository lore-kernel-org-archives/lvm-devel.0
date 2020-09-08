From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Sep 2020 22:03:42 +0000 (GMT)
Subject: master - raid: do not enforce flushing of raids when it is not required
Message-ID: <20200908220342.B8A933857030@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce5ea07411d57a2bd276d8d29e46ce30b957f657
Commit:        ce5ea07411d57a2bd276d8d29e46ce30b957f657
Parent:        3388e194892e9ab7a36b72e512796c2d218dae6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 8 21:09:06 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 21:23:03 2020 +0200

raid: do not enforce flushing of raids when it is not required

This is probably somewhat experimantal patch - but when i.e. raid device
is just extend, there should not be a technical need for flush,
unless the target would stricly need it.  It should allow faster
processing of lvm command not being blocked by possibly longer flush.
---
 WHATS_NEW               | 1 +
 lib/activate/activate.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aa3960b31..0aa23046d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Allow raid extension without flushing raid LV first.
   Use _rmeta and _rimage as origin only devices for table loading.
   Switch code base to use flexible array syntax.
   Fix 64bit math when calculation cachevol size.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 0c6bd1a9a..c5adc5065 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2177,7 +2177,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	 * TODO: Relax this limiting condition further */
 	if (!flush_required &&
 	    (lv_is_pvmove(lv) || pvmove_lv ||
-	     (!lv_is_mirror(lv) && !lv_is_thin_pool(lv) && !lv_is_thin_volume(lv)))) {
+	     (!lv_is_raid(lv) && !lv_is_mirror(lv) && !lv_is_thin_pool(lv) && !lv_is_thin_volume(lv)))) {
 		log_debug("Requiring flush for LV %s.", display_lvname(lv));
 		flush_required = 1;
 	}


