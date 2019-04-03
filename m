From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 3 Apr 2019 07:29:59 -0400
Subject: master - thin: fix maintenance of _pmspare
Message-ID: <201904031129.x33BTxbg027567@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fcec6691f074f1123b9c04c3130f84e35d195b01
Commit:        fcec6691f074f1123b9c04c3130f84e35d195b01
Parent:        e27d0271557d4b93e87a70854b3c7f1cc6008155
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 3 13:02:50 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 3 13:28:54 2019 +0200

thin: fix maintenance of _pmspare

When metadata grows lvm2 may need to extend also _pmspare volume.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 00c96b5..81c3d71 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Fix missing growth of _pmsmare volume when extending _tmeta volume.
   Automatically grow thin metadata, when thin data gets too big.
   Add synchronization with udev before removing cached devices.
   Add support for caching VDO LVs and VDOPOOL LVs.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a13ba31..76d18b0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5539,6 +5539,10 @@ static int _lvresize_volume(struct logical_volume *lv,
 					display_lvname(lv),
 					display_size(cmd, (uint64_t) old_extents * vg->extent_size), old_extents,
 					display_size(cmd, (uint64_t) lv->le_count * vg->extent_size), lv->le_count);
+
+		/* Resizing metadata and PV list is not specified -> maintain size of _pmspare volume */
+		if ((&vg->pvs == pvh) && lv_is_pool_metadata(lv))
+			(void) handle_pool_metadata_spare(vg, 0, pvh, 1);
 	}
 
 	return 1;


