From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Dec 2018 09:23:53 -0500
Subject: master - lvmanip: uninitialized members in struct pv_list (#10)
Message-ID: <201812141423.wBEENr3G011125@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=859feb81e5b61ac2109b1d7850844ccf1ce3e5bf
Commit:        859feb81e5b61ac2109b1d7850844ccf1ce3e5bf
Parent:        db6d9e04af7277a5e2883743e0a9a1502d97249f
Author:        Ming-Hung Tsai <notifications@github.com>
AuthorDate:    Fri Dec 14 01:51:51 2018 -0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 15:23:18 2018 +0100

lvmanip:  uninitialized members in struct pv_list (#10)

Scenario: Given an existed LV `lvol0`, I want to create another LV
on the PVs used by `lvol0`.

I use `build_parallel_areas_from_lv()` to obtain the `pv_list` of each segments.
However, the returned `pv_list` is not properly initialized, which causes
segfault in subsequent operations.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6856d66..0b7f834 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Fix missing proper initialization of pv_list struct when adding pv.
   Fix (de)activation of RaidLVs with visible SubLVs
   Prohibit mirrored 'mirror' log via lvcreate and lvconvert
   Use sync io if async io_setup fails, or use_aio=0 is set in config.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2c569d8..27c40d7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5962,7 +5962,7 @@ static int _add_pvs(struct cmd_context *cmd, struct pv_segment *peg,
 	if (find_pv_in_pv_list(&spvs->pvs, peg->pv))
 		return 1;
 
-	if (!(pvl = dm_pool_alloc(cmd->mem, sizeof(*pvl)))) {
+	if (!(pvl = dm_pool_zalloc(cmd->mem, sizeof(*pvl)))) {
 		log_error("pv_list allocation failed");
 		return 0;
 	}


