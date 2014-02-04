From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Feb 2014 13:51:40 +0000 (UTC)
Subject: master - raid: add temporary activation for raid metadata clear
Message-ID: <20140204135140.2305261295@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef6c5795a0b0502b5ef984233fbeb73a9d81f2d0
Commit:        ef6c5795a0b0502b5ef984233fbeb73a9d81f2d0
Parent:        ef557b8091ff67f38424d3f8413f3a543275b01d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 4 14:47:52 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 14:51:05 2014 +0100

raid: add temporary activation for raid metadata clear

Use LV_TEMPORARY when activating devices for clearing
raid metadata.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 25293e6..dbacf01 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Avoid exposing temporary devices when initializing raid metadata volumes.
   Add internal tags command to display any tags defined on the host.
   Prohibit use of external origin with size incompatible with thin pool.
   Avoid trying to convert single to thin pool and volume at the same time.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a29ea85..3f2b043 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -174,11 +174,13 @@ static int _clear_lv(struct logical_volume *lv)
 	if (test_mode())
 		return 1;
 
-	if (!was_active && !activate_lv_excl_local(lv->vg->cmd, lv)) {
-		log_error("Failed to activate %s for clearing",
+	lv->status |= LV_TEMPORARY;
+	if (!was_active && !activate_lv_local(lv->vg->cmd, lv)) {
+		log_error("Failed to activate localy %s for clearing",
 			  lv->name);
 		return 0;
 	}
+	lv->status &= ~LV_TEMPORARY;
 
 	log_verbose("Clearing metadata area of %s/%s",
 		    lv->vg->name, lv->name);


