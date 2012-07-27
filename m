From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 27 Jul 2012 19:20:03 +0000 (UTC)
Subject: master - reports: invalid snaps do not capitalise lv_attr
Message-ID: <20120727192003.54EAF577C@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4dbf872a9fc0aac34f73fd8214cc75846554e501
Commit:        4dbf872a9fc0aac34f73fd8214cc75846554e501
Parent:        25ae0b39b77d80990d0821729ab4f2307bd38c16
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 27 20:19:28 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 27 20:19:28 2012 +0100

reports: invalid snaps do not capitalise lv_attr

No longer capitalise first LV attribute char for invalid snapshots.
This state is available from the 5th char now (I or S).
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    1 -
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 32ebf15..a09e076 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  No longer capitalise first LV attribute char for invalid snapshots.
   Allow vgextend to add PVs to a VG that is missing PVs.
   Recognise Micron PCIe SSDs in filter and move array out to device-types.h.
   Fix segfault when attempting to replace RAID 4/5/6 device (2.02.97).
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 747bf9e..bb6043d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -448,7 +448,6 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		if (info.live_table && lv_is_cow(lv)) {
 			if (!lv_snapshot_percent(lv, &snap_percent) ||
 			    snap_percent == PERCENT_INVALID) {
-				repstr[0] = toupper(repstr[0]);
 				if (info.suspended)
 					repstr[4] = 'S'; /* Susp Inv snapshot */
 				else


