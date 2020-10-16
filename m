From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:12 +0000 (GMT)
Subject: stable-2.02 - thin: compensate metadata size by extra percent
Message-ID: <20201016191112.2B46B396EC83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b1f67da0699d408477b6cdd79cdd34f8b4b98cd
Commit:        6b1f67da0699d408477b6cdd79cdd34f8b4b98cd
Parent:        e5066339a5c61c5d5e8cd365071526cdd07ec04c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 13:31:55 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

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
index 86c0274b3..c902ccde5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Use extra 1% when resizing thin-pool metadata LV with --use-policy.
   Enhance --use-policy percentage rounding.
   Switch code base to use flexible array syntax.
   Preserve uint32_t for seqno handling.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index affce9433..74b2afa96 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4724,7 +4724,9 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 		min_threshold = pool_metadata_min_threshold(first_seg(lv)) / DM_PERCENT_1;
 		*meta_amount = _adjust_amount(percent, (min_threshold < policy_threshold) ?
 					      min_threshold : policy_threshold, policy_amount);
-
+		if (*meta_amount)
+			/* Compensate possible extra space consumption by kernel on resize */
+			(*meta_amount)++;
 		if (!lv_thin_pool_percent(lv, 0, &percent))
 			return_0;
 	} else {


