From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 07:54:05 -0400
Subject: master - raid: move syncing with udev into function
Message-ID: <201707201154.v6KBs5LO032067@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c78316b7a5341aa9259c118988e659d38ef862f2
Commit:        c78316b7a5341aa9259c118988e659d38ef862f2
Parent:        7b048f6b43a7cb752bae44fbed0da8508b24b959
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 20 13:46:39 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 13:52:18 2017 +0200

raid: move syncing with udev into function

Since _deactivate_and_remove_lvs() is used in more then one place,
move the needed udev synchronization into this function so other
users automatically get correct fs state before next dm manipulation.

Assumption here is that this udev synchronization 'delay' may also
prevent to 'early' table reloads which might cause kernel problems
for md-core - but we may need more generic time-limited reload
frequency for raid devices.

Note: on udev-less system there will be almost no delay.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   14 +++++++-------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 48ec679..c587a9c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.173 - 
 =================================
+  Add synchornization points with udev during conversion of raid LVs.
   Improve --size args validation and report more detailed error message.
   Initialize debugging mutex before any debug message in clvmd.
   Log error instad of warn when noticing connection problem with lvmetad.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 895bb73..e275da1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -329,6 +329,13 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
 			return_0;
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
 
@@ -3852,13 +3859,6 @@ static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
 	if (!_deactivate_and_remove_lvs(vg, removal_lvs))
 		return_0;
 
-	/* Wait for events following any deactivation. */
-	if (!sync_local_dev_names(vg->cmd)) {
-		log_error("Failed to sync local devices after removing %u LVs in VG %s.",
-			  dm_list_size(removal_lvs), vg->name);
-		return 0;
-	}
-
 	dm_list_init(removal_lvs);
 
 	if (vg_write_requested) {


