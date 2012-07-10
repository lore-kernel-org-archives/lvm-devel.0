From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Jul 2012 13:38:03 +0000 (UTC)
Subject: master - lvconvert: count % upwards when merging a snapshot
Message-ID: <20120710133803.3F976116A@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07e4ac7b00f680ad88aa0ff4c835ea2b27eab44b
Commit:        07e4ac7b00f680ad88aa0ff4c835ea2b27eab44b
Parent:        cd8ea8b437de53f0019bd69d542a7d01f3d5b7d3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 10 15:30:18 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 10 15:30:18 2012 +0200

lvconvert: count % upwards when merging a snapshot

Before:
  # lvconvert --merge -i 1 vg/lvol1
  Merging of volume lvol1 started.
  lvol0: Merged: 36.7%
  lvol0: Merged: 21.3%
  lvol0: Merged: 5.8%
  lvol0: Merged: 0.0%
  Merge of snapshot into logical volume lvol0 has finished.
  Logical volume "lvol1" successfully removed

After:
  # lvconvert --merge -i 1 vg/lvol1
  Merging of volume lvol1 started.
  lvol0: Merged: 61.4%
  lvol0: Merged: 73.0%
  lvol0: Merged: 88.4%
  lvol0: Merged: 100.0%
  Merge of snapshot into logical volume lvol0 has finished.
  Logical volume "lvol1" successfully removed
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9d6f091..f20f4fb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Count percentage of completeness upwards when merging a snapshot volume.
   Skip activation when using vg/lvchange --sysinit -a ay and lvmetad is active.
   Fix extending RAID 4/5/6 logical volumes
   Fix test for PV with unknown VG in process_each_pv to ignore ignored mdas.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 074821d..76cc9b3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -580,10 +580,10 @@ static progress_t _poll_merge_progress(struct cmd_context *cmd,
 
 	if (parms->progress_display)
 		log_print("%s: %s: %.1f%%", lv->name, parms->progress_title,
-			  percent_to_float(percent));
+			  100.0 - percent_to_float(percent));
 	else
 		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title,
-			    percent_to_float(percent));
+			    100.0 - percent_to_float(percent));
 
 	if (percent == PERCENT_0)
 		return PROGRESS_FINISHED_ALL;


