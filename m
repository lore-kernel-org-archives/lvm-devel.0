From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:09 +0000 (GMT)
Subject: stable-2.02 - lvextend: improve percentage estimation
Message-ID: <20201016191109.D7517396EC45@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5190e16c30dcf3ed76a756ff0a5e54342f477abd
Commit:        5190e16c30dcf3ed76a756ff0a5e54342f477abd
Parent:        68f94a2dd38da38d705051b055caf231ad6fb100
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 22:38:34 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

lvextend: improve percentage estimation

Correcting rounding rules for percentage evaluation.

Validate supported range of percentage.
(although ranges are already validated earlier on code path)
---
 WHATS_NEW               | 1 +
 lib/metadata/lv_manip.c | 5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 32dcd5f34..86c0274b3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Enhance --use-policy percentage rounding.
   Switch code base to use flexible array syntax.
   Preserve uint32_t for seqno handling.
   Switch from mmap to plain read when loading regular files.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 945f5cb60..affce9433 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4652,7 +4652,7 @@ static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 
 static uint32_t _adjust_amount(dm_percent_t percent, int policy_threshold, int policy_amount)
 {
-	if (!(DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) ||
+	if (!((50 * DM_PERCENT_1) < percent && percent <= DM_PERCENT_100) ||
 	    percent <= (policy_threshold * DM_PERCENT_1))
 		return 0; /* nothing to do */
 	/*
@@ -4660,7 +4660,8 @@ static uint32_t _adjust_amount(dm_percent_t percent, int policy_threshold, int p
 	 * Keep using DM_PERCENT_1 units for better precision.
 	 * Round-up to needed percentage value
 	 */
-	percent = (percent / policy_threshold + (DM_PERCENT_1 - 1) / 100) / (DM_PERCENT_1 / 100) - 100;
+	policy_threshold *= (DM_PERCENT_1 / 100);
+	percent = (percent + policy_threshold - 1) / policy_threshold - 100;
 
 	/* Use it if current policy amount is smaller */
 	return (policy_amount < percent) ? (uint32_t) percent : (uint32_t) policy_amount;


