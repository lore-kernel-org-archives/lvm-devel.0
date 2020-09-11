From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 11 Sep 2020 19:53:43 +0000 (GMT)
Subject: master - thin: compensate metadata size by extra percent
Message-ID: <20200911195343.DE44A386F027@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9f78acfee9e1f50ea58b532880c5e3e2f6161105
Commit:        9f78acfee9e1f50ea58b532880c5e3e2f6161105
Parent:        b798554a20147535566576fce8d2c839a090cf84
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 13:31:55 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:42:37 2020 +0200

thin: compensate metadata size by extra percent

When using --use-policy for automatic extension of thin-pool,
the extension of thin-pool's metadata itself can actually take
some extra space.
Since I'm not aware of exact compensation formula, add just
1% extra to calculated amount and hope it fits.

Wanted target is to always have usable thin-pool that fits
bellow pool_metadata_min_threshold().
---
 WHATS_NEW               | 1 +
 lib/metadata/lv_manip.c | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ebbeb2718..a96f488c7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Use extra 1% when resizing thin-pool metadata LV with --use-policy.
   Enhance --use-policy percentage rounding.
   Configure --with-vdo and --with-writecache as internal segments.
   Improving VDO man page examples.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3c781dcf9..70ac8a799 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5010,7 +5010,9 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 		min_threshold = pool_metadata_min_threshold(first_seg(lv)) / DM_PERCENT_1;
 		*meta_amount = _adjust_amount(percent, (min_threshold < policy_threshold) ?
 					      min_threshold : policy_threshold, policy_amount);
-
+		if (*meta_amount)
+			/* Compensate possible extra space consumption by kernel on resize */
+			(*meta_amount)++;
 		if (!lv_thin_pool_percent(lv, 0, &percent))
 			goto_bad;
 	} else if (lv_is_vdo_pool(lv)) {


