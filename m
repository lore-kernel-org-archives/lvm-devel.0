From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 26 Aug 2013 21:41:18 +0000 (UTC)
Subject: master - pvmove: Allow moving snapshot/origin. Disallow converting and merging LVs
Message-ID: <20130826214118.DA0E361019@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ef48b91ed74f732b6150a9492da624d204b331d
Commit:        2ef48b91ed74f732b6150a9492da624d204b331d
Parent:        caa77b33f2d5e59f2906b9f08f59ac2e64b14682
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Aug 26 16:36:30 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Aug 26 16:36:30 2013 -0500

pvmove:  Allow moving snapshot/origin.  Disallow converting and merging LVs

The patch allows the user to also pvmove snapshots and origin logical
volumes.  This means pvmove should be able to move all segment types.
I have, however, disallowed moving converting or merging logical volumes.
---
 WHATS_NEW       |    2 ++
 man/pvmove.8.in |    5 -----
 tools/pvmove.c  |   12 +++++++-----
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 069c3c2..29af78d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.101 - 
 ===================================
+  Disable pvmove of merging or converting logical volumes.
+  Enable pvmove of snapshots and snapshot origins.
   Fix inability to specify LV name when pvmove'ing a RAID, mirror, or thin-LV.
   Inform lvmetad about any lost PV label to make it in sync with system state.
   Support most of lvchange operations on stacked thin pool meta/data LVs.
diff --git a/man/pvmove.8.in b/man/pvmove.8.in
index ba6ea1e..79ccf1c 100644
--- a/man/pvmove.8.in
+++ b/man/pvmove.8.in
@@ -75,9 +75,6 @@ is updated so that the Logical Volumes reflect the new data locations.
 Note that this new process cannot support the original LVM1
 type of on-disk metadata.  Metadata can be converted using \fBvgconvert\fP(8).
 
-N.B. The moving of non-thinly provisioned snapshots and their
-origins is not supported.
-
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
@@ -110,8 +107,6 @@ To move all Physical Extents that are used by simple Logical Volumes on
 .sp
 .B pvmove /dev/sdb1
 .P
-Any non-thinly provisioned snapshots and their origins are left unchanged.
-.P
 Additionally, a specific destination device /dev/sdc1
 can be specified like this:
 .sp
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 2868290..1007370 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -295,6 +295,13 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;
 
+		if (lv->status & (CONVERTING | MERGING)) {
+			log_error("Unable to pvmove when %s volumes are present",
+				  (lv->status & CONVERTING) ?
+				  "converting" : "merging");
+			return NULL;
+		}
+
 		if (seg_is_raid(first_seg(lv)) ||
 		    seg_is_mirrored(first_seg(lv))) {
 			dm_list_init(&trim_list);
@@ -327,11 +334,6 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;
 
-		if (lv_is_origin(lv) || lv_is_cow(lv)) {
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping snapshot-related LV %s", lv->name);
-			continue;
-		}
 		seg = first_seg(lv);
 		if (seg_is_raid(seg) || seg_is_mirrored(seg) ||
 		    lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) {


