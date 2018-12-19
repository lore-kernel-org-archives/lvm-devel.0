From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 19 Dec 2018 03:19:04 -0500
Subject: 2018-06-01-stable - lvmanip: uninitialized members in struct pv_list (#10)
Message-ID: <201812190819.wBJ8J4qa019624@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df0797db8cec82df92fb1df2bace184f5a811924
Commit:        df0797db8cec82df92fb1df2bace184f5a811924
Parent:        2d077286b9c6b07fcdd62d834274ae9ab896b195
Author:        Ming-Hung Tsai <notifications@github.com>
AuthorDate:    Fri Dec 14 01:51:51 2018 -0800
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Dec 19 09:18:25 2018 +0100

lvmanip:  uninitialized members in struct pv_list (#10)

Scenario: Given an existed LV `lvol0`, I want to create another LV
on the PVs used by `lvol0`.

I use `build_parallel_areas_from_lv()` to obtain the `pv_list` of each segments.
However, the returned `pv_list` is not properly initialized, which causes
segfault in subsequent operations.

(cherry picked from commit 859feb81e5b61ac2109b1d7850844ccf1ce3e5bf)
(cherry picked from commit 219ba4f54a462c175f5e9acaa0558afac94d5ff7)

Conflicts:
	WHATS_NEW
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 02f4ebf..4d1ece4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.184 - 
 =====================================
+  Fix missing proper initialization of pv_list struct when adding pv.
 
 Version 2.02.183 - 07th December 2018
 =====================================
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e4293cc..d1389e7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5860,7 +5860,7 @@ static int _add_pvs(struct cmd_context *cmd, struct pv_segment *peg,
 	if (find_pv_in_pv_list(&spvs->pvs, peg->pv))
 		return 1;
 
-	if (!(pvl = dm_pool_alloc(cmd->mem, sizeof(*pvl)))) {
+	if (!(pvl = dm_pool_zalloc(cmd->mem, sizeof(*pvl)))) {
 		log_error("pv_list allocation failed");
 		return 0;
 	}


