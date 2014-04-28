From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 28 Apr 2014 10:43:39 +0000 (UTC)
Subject: master - display: use Virtual for virtual LV
Message-ID: <20140428104339.1B51D60D59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6168b8d70935004e38bc2f1ac9d57cc0bf6df10
Commit:        e6168b8d70935004e38bc2f1ac9d57cc0bf6df10
Parent:        5b28cbd7c2cd8413c189fff1286a579174ca082a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 28 11:19:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 28 12:37:50 2014 +0200

display: use Virtual for virtual LV

Emphesize virtual extents for virtual LVs and for
those use  'Virtual extents' instead of 'Logical extents',
so it's immeditatelly visible, which extents do have
straighforward physical backend.
---
 WHATS_NEW             |    1 +
 lib/display/display.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3f879c9..cd649da 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Display virtual extents for virtual LVs in 'lvdisplay --maps'.
   Make vgsplit fail cleanly when not all PVs are specified for RAID 4/5/6.
   Make vgsplit work on mirrors with logs that share PVs with images.
   Use devices/ignore_suspended_devices=0 by default if not defined in lvm.conf.
diff --git a/lib/display/display.c b/lib/display/display.c
index c93b2b3..a34d947 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -661,7 +661,8 @@ int lvdisplay_segments(const struct logical_volume *lv)
 	log_print("--- Segments ---");
 
 	dm_list_iterate_items(seg, &lv->segments) {
-		log_print("Logical extent %u to %u:",
+		log_print("%s extents %u to %u:",
+			  lv_is_virtual(lv) ? "Virtual" : "Logical",
 			  seg->le, seg->le + seg->len - 1);
 
 		log_print("  Type\t\t%s", seg->segtype->ops->name(seg));


