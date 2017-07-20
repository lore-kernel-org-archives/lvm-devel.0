From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 13:17:38 -0400
Subject: master - raid: reshape synchronization point
Message-ID: <201707201717.v6KHHcQT023955@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39ebacdb5a4df1c9e1ef1258082de40d0bff1cba
Commit:        39ebacdb5a4df1c9e1ef1258082de40d0bff1cba
Parent:        8e0c5d0cb6385df11c7f65a8d5eb0e846cd31dd9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 20 19:04:59 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 19:16:39 2017 +0200

raid: reshape synchronization point

Give udev time to get in sync and give md-core time to wake up
after table reload.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   13 +++++++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a5eef63..a9b3a08 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Add synchronization points with udev during reshape of raid LVs.
 
 Version 2.02.173 - 20th July 2017
 =================================
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b90d6f4..0432928 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3853,6 +3853,12 @@ static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
 						      struct dm_list *removal_lvs,
 						      int vg_write_requested)
 {
+	if (!sync_local_dev_names(vg->cmd)) {
+		log_error("Failed to sync local devices after removing %u LVs in VG %s.",
+			  dm_list_size(removal_lvs), vg->name);
+		return 0;
+	}
+
 	if (!removal_lvs || dm_list_empty(removal_lvs))
 		return 1;
 
@@ -3868,6 +3874,13 @@ static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
 		backup(vg);
 	}
 
+	/* Wait for events following any deactivation. */
+	if (!sync_local_dev_names(vg->cmd)) {
+		log_error("Failed to sync local devices after removing %u LVs in VG %s.",
+			  dm_list_size(removal_lvs), vg->name);
+		return 0;
+	}
+
 	return 1;
 }
 


