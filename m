From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:32 +0000 (UTC)
Subject: master - snapshot: check merging_cow is cow
Message-ID: <20160527134732.AC2756050D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26889b3bb636b5655620f25c38db2c6759bf708d
Commit:        26889b3bb636b5655620f25c38db2c6759bf708d
Parent:        e9ee2cb6b6cf20893ab753d7129f759ba8faa931
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 27 13:49:30 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

snapshot: check merging_cow is cow

Check first the LV is cow before even checking it's a merging COW.
Note: previosly merging_cow was also merging origin, so without
this explicit check it used to return '1' also when passed
LV has been merging origin.
---
 WHATS_NEW                     |    1 +
 lib/metadata/snapshot_manip.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2b6e0fb..aa352a2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  When checking LV is a merging COW, validate its a COW LV first.
   Correcting value in copy_percent() for 100%.
   Update vgreduce to use process_each_vg.
   Update lvconvert to use process_each_lv.
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 29b851f..2f13ac9 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -139,7 +139,12 @@ int lv_is_visible(const struct logical_volume *lv)
 
 int lv_is_merging_cow(const struct logical_volume *cow)
 {
-	struct lv_segment *snap_seg = find_snapshot(cow);
+	struct lv_segment *snap_seg;
+
+	if (!lv_is_cow(cow))
+		return 0;
+
+	snap_seg = find_snapshot(cow);
 
 	/* checks lv_segment's status to see if snapshot is merging */
 	return (snap_seg && (snap_seg->status & MERGING)) ? 1 : 0;


