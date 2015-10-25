From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 25 Oct 2015 20:09:54 +0000 (UTC)
Subject: master - thin: fix percentage compare
Message-ID: <20151025200954.A129560E5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b780d329aa9ce249bf5164154c81cefd9b276970
Commit:        b780d329aa9ce249bf5164154c81cefd9b276970
Parent:        8f269697d21035035ffb4954f31bd702a6dd7ca8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 19:13:53 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 21:01:54 2015 +0100

thin: fix percentage compare

Since plugin's percentage compare has been fixed,
it's now revealed wrong compare here.

The logic for threshold is - to allow to go as high
as given value e.g. 80% - so if pool is exactlu 80%
full it's still allowed to use it (dmeventd will not
resize it).
---
 WHATS_NEW                 |    1 +
 lib/metadata/thin_manip.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5911c64..0495e46 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Correct percentage evaluation when checking thin-pool over threshold.
   Fix lvmcache to move PV from VG to orphans if VG is removed and lvmetad used.
   Fix lvmcache to not cache even invalid info about PV which got removed.
   Support checking of memlock daemon counter.
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 37bf4cb..6b22ce5 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -224,7 +224,7 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 	if (!lv_thin_pool_percent(pool_seg->lv, 0, &percent))
 		return_0;
 
-	if (percent >= threshold) {
+	if (percent > threshold) {
 		log_debug("Threshold configured for free data space in "
 			  "thin pool %s has been reached (%.2f%% >= %.2f%%).",
 			  display_lvname(pool_seg->lv),
@@ -237,7 +237,7 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 	if (!lv_thin_pool_percent(pool_seg->lv, 1, &percent))
 		return_0;
 
-	if (percent >= threshold) {
+	if (percent > threshold) {
 		log_debug("Threshold configured for free metadata space in "
 			  "thin pool %s has been reached (%.2f%% > %.2f%%).",
 			  display_lvname(pool_seg->lv),


