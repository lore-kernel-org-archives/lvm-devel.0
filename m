From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 28 Jun 2012 23:55:51 +0000 (UTC)
Subject: master - alloc: fix raid --alloc anywhere double allocs
Message-ID: <20120628235551.54B841719@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2cec4b4a7748cefe4e2b8adcd1c287af354e21fb
Commit:        2cec4b4a7748cefe4e2b8adcd1c287af354e21fb
Parent:        2f201d0e5e2149455709efa8bb977bd612694a5e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jun 28 23:26:42 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jun 28 23:26:42 2012 +0100

alloc: fix raid --alloc anywhere double allocs

If _alloc_parallel_area for raid devices chooses an area already used
up, it doesn't notice that it has no space left in it and leaves
later code trying to place a zero-length area into the LV.

https://bugzilla.redhat.com/832596
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 71c8219..4be4c90 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Fix _alloc_parallel_area to avoid picking already-full areas for raid devices.
   Use vgchange -aay instead of vgchange -ay in clmvd init script.
   Add activation/auto_activation_volume_list to lvm.conf.
   Add --activate ay to lvcreate, lvchange, pvscan and vgchange.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0666a51..21508fd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1132,9 +1132,13 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 			dm_list_add(&ah->alloced_areas[s], &aa[s].list);
 			s -= ah->area_count + ah->parity_count;
 		}
+		aa[s].len = (ah->alloc_and_split_meta) ? len - ah->log_len : len;
+		/* Skip empty allocations */
+		if (!aa[s].len)
+			continue;
+
 		aa[s].pv = pva->map->pv;
 		aa[s].pe = pva->start;
-		aa[s].len = (ah->alloc_and_split_meta) ? len - ah->log_len : len;
 
 		log_debug("Allocating parallel area %" PRIu32
 			  " on %s start PE %" PRIu32 " length %" PRIu32 ".",


