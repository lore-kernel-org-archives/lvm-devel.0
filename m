From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 16 Sep 2013 15:59:37 +0000 (UTC)
Subject: master - filters: Add bcache.
Message-ID: <20130916155937.D9EA560DD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97ba18f4cbedbdf7933d30d719cf997bb06e7214
Commit:        97ba18f4cbedbdf7933d30d719cf997bb06e7214
Parent:        10bc19ec1070d16d7367285856ebba7f99cf1996
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 16 16:56:55 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 16 16:56:55 2013 +0100

filters: Add bcache.

N.B. Using bcache devices as PVs is still experimental.
Problems should be reported to the appropriate mailing lists.
---
 WHATS_NEW                 |    8 +++-----
 lib/device/device-types.h |    1 +
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1c4925b..d51f08c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Recognise bcache block devices in filter (experimental).
   Run lvm2-activation-net after lvm2-activation service to prevent parallel run.
   Add man page entries for lvmdump's -u and -l options.
   Fix lvm2app segfault while using lvm_list_pvs_free fn if there are no PVs.
@@ -14,19 +15,16 @@ Version 2.02.101 -
   Fix dmeventd unmonitoring of thin pools.
   Fix lvresize for stacked thin pool volumes (i.e. mirrors).
   Write Completed debug message before reinstating log defaults after command.
-  Skip pvmove of RAID, thin, snapshot, origin, or mirror LVs in a cluster.
   Refresh existing VG before autoactivation (event retrigger/device reappeared).
   Use pvscan -b in udev rules to avoid a deadlock on udev process count limit.
   Add pvscan -b/--background for the command to be processed in the background.
   Don't assume stdin file descriptor is readable.
   Avoid unlimited recursion when creating dtree containing inactive pvmove LV.
   Require exactly 3 arguments for lvm2-activation-generator. Remove defaults.
-  Disable pvmove of merging or converting logical volumes.
-  Enable pvmove of snapshots and snapshot origins.
-  Fix inability to specify LV name when pvmove'ing a RAID, mirror, or thin-LV.
   Inform lvmetad about any lost PV label to make it in sync with system state.
   Support most of lvchange operations on stacked thin pool meta/data LVs.
-  Add ability to pvmove RAID, mirror, and thin volumes.
+  Enable non-clustered pvmove of snapshots and snapshot origins.
+  Add ability to pvmove non-clustered RAID, mirror, and thin volumes.
   Make lvm2-activation-generator silent unless it's in error state.
   Remove "mpath major is not dm major" msg for mpath component scan (2.02.94).
   Prevent cluster mirror logs from being corrupted by redundant checkpoints.
diff --git a/lib/device/device-types.h b/lib/device/device-types.h
index 48ae32a..d25c2f0 100644
--- a/lib/device/device-types.h
+++ b/lib/device/device-types.h
@@ -60,5 +60,6 @@ static const dev_known_type_t _dev_known_types[] = {
 	{"vtms", 16, "Violin Memory"},
 	{"skd", 16, "STEC"},
 	{"scm", 8, "Storage Class Memory (IBM S/390)"},
+	{"bcache", 1, "bcache block device cache"},
 	{"", 0, ""}
 };


