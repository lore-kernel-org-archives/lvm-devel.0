From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 14 May 2014 15:26:06 +0000 (UTC)
Subject: master - allocation: Fix alloc anywhere with parity.
Message-ID: <20140514152606.CEAF260CD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b989e317fecf115ce9a2b89f777e4feec2461ec
Commit:        3b989e317fecf115ce9a2b89f777e4feec2461ec
Parent:        422b3b0fb53d83bc3ffbd35f7d7505a1938cb24c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed May 14 16:25:43 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed May 14 16:25:43 2014 +0100

allocation: Fix alloc anywhere with parity.

Take account of parity areas with alloc anywhere in
_calc_required_extents.  Extents beyond area_count were treated
incorrectly as mirror logs.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    5 ++---
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 88ae713..8bcf687 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Take account of parity areas with alloc anywhere in _calc_required_extents.
   Use proper uint64 casting for calculation of cache metadata size.
   Better support for nesting of blocking signals.
   Use only sigaction handler and drop duplicate signal handler.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2005826..fa08c39 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1432,8 +1432,7 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 	struct alloced_area *aa;
 	struct pv_area *pva;
 
-	total_area_count = ah->area_count + alloc_state->log_area_count_still_needed;
-	total_area_count += ah->parity_count;
+	total_area_count = ah->area_count + ah->parity_count + alloc_state->log_area_count_still_needed;
 	if (!total_area_count) {
 		log_warn(INTERNAL_ERROR "_alloc_parallel_area called without any allocation to do.");
 		return 1;
@@ -1980,7 +1979,7 @@ static uint32_t _calc_required_extents(struct alloc_handle *ah, struct pv_area *
 	 * reduce amount we're looking for.
 	 */
 	if (alloc == ALLOC_ANYWHERE) {
-		if (ix_pva >= ah->area_count)
+		if (ix_pva >= ah->area_count + ah->parity_count)
 			required = ah->log_len;
 	} else if (required < ah->log_len)
 		required = ah->log_len;


