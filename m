From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue,  3 Sep 2013 18:18:12 +0000 (UTC)
Subject: master - pvmove: Skip pvmove of RAID, thin, snapshot, origin, and mirror LVs in cluster
Message-ID: <20130903181812.8BBA060DFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc66dedc0ebe9a7f7718d6340ccd6247d1a471e1
Commit:        cc66dedc0ebe9a7f7718d6340ccd6247d1a471e1
Parent:        7918217c754555fc685851e7d80f86a8f6c8abcb
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 3 13:17:01 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 3 13:17:01 2013 -0500

pvmove: Skip pvmove of RAID, thin, snapshot, origin, and mirror LVs in cluster

pvmove of the above types should only have been enabled in single machine
mode.
---
 WHATS_NEW      |    1 +
 tools/pvmove.c |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8134714..abfe0e1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Skip pvmove of RAID, thin, snapshot, origin, or mirror LVs in a cluster.
   Refresh existing VG before autoactivation (event retrigger/device reappeared).
   Use pvscan -b in udev rules to avoid a deadlock on udev process count limit.
   Add pvscan -b/--background for the command to be processed in the background.
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 1007370..ab2e03b 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -292,6 +292,14 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (lv_name && strcmp(lv->name, lv_name))
 			continue;
 
+		/*
+		 * RAID, thin, mirror, and snapshot-related LVs are not
+		 * processed in a cluster, so we don't have to worry about
+		 * avoiding certain PVs in that context.
+		 */
+		if (vg_is_clustered(lv->vg))
+			continue;
+
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;
 
@@ -334,6 +342,36 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;
 
+		/*
+		 * If the VG is clustered, we are unable to handle
+		 * snapshots, origins, thin types, RAID or mirror
+		 */
+		if (vg_is_clustered(vg) &&
+		    (lv_is_origin(lv) || lv_is_cow(lv) ||
+		     lv_is_thin_type(lv) || lv_is_raid_type(lv) ||
+		     lv_is_mirrored(lv))) {
+			log_print_unless_silent("Skipping %s LV %s",
+						lv_is_origin(lv) ? "origin" :
+						lv_is_cow(lv) ?
+						"snapshot-related" :
+						lv_is_thin_volume(lv) ? "thin" :
+						lv_is_thin_pool(lv) ?
+						"thin-pool" :
+						lv_is_thin_type(lv) ?
+						"thin-related" :
+						seg_is_raid(first_seg(lv)) ?
+						"RAID" :
+						lv_is_raid_type(lv) ?
+						"RAID-related" :
+						lv_is_mirrored(lv) ?
+						"mirror" :
+						lv_is_mirror_type(lv) ?
+						"mirror-related" : "",
+						lv->name);
+			lv_skipped = 1;
+			continue;
+		}
+
 		seg = first_seg(lv);
 		if (seg_is_raid(seg) || seg_is_mirrored(seg) ||
 		    lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) {


