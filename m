From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 10 Sep 2020 21:56:16 +0000 (GMT)
Subject: master - lvextend: improve percentage estimation
Message-ID: <20200910215616.C25483985443@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7f5acdfa674af473f31b23413afb1875cb3e078
Commit:        e7f5acdfa674af473f31b23413afb1875cb3e078
Parent:        6d392776b0c65c02f53435cbc1adbbb6765dfaa6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 22:38:34 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 23:54:31 2020 +0200

lvextend: improve percentage estimation

Correcting rounding rules for percentage evaluation.

Validate supported range of percentage.
(although ranges are already validated earlier on code path)
---
 WHATS_NEW               | 1 +
 lib/metadata/lv_manip.c | 4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1171eb2a9..ebbeb2718 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Enhance --use-policy percentage rounding.
   Configure --with-vdo and --with-writecache as internal segments.
   Improving VDO man page examples.
   Switch code base to use flexible array syntax.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d72c49bea..ba143075d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4932,7 +4932,7 @@ static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 
 static uint32_t _adjust_amount(dm_percent_t percent, int policy_threshold, int policy_amount)
 {
-	if (!(DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) ||
+	if (!((50 * DM_PERCENT_1) < percent && percent <= DM_PERCENT_100) ||
 	    percent <= (policy_threshold * DM_PERCENT_1))
 		return 0; /* nothing to do */
 	/*
@@ -4940,7 +4940,7 @@ static uint32_t _adjust_amount(dm_percent_t percent, int policy_threshold, int p
 	 * Keep using DM_PERCENT_1 units for better precision.
 	 * Round-up to needed percentage value
 	 */
-	percent = (percent / policy_threshold + (DM_PERCENT_1 - 1) / 100) / (DM_PERCENT_1 / 100) - 100;
+	percent = ((percent + policy_threshold - 1) / policy_threshold) / (DM_PERCENT_1 / 100) - 100;
 
 	/* Use it if current policy amount is smaller */
 	return (policy_amount < percent) ? (uint32_t) percent : (uint32_t) policy_amount;


