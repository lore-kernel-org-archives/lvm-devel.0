From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 10 Jan 2011 14:56:38 -0600
Subject: [PATCH 2 of 4] LVM: cleanup 2
Message-ID: <201101102056.p0AKucDj011961@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-cleanup-2.patch

The check for segtype_is_virtual is done at the top of the function,
no need to do it again at the bottom.


Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -1557,8 +1557,7 @@ struct alloc_handle *allocate_extents(st
 			       parallel_areas)))
 		return_NULL;
 
-	if (!segtype_is_virtual(segtype) &&
-	    !_allocate(ah, vg, lv, 1, allocatable_pvs)) {
+	if (!_allocate(ah, vg, lv, 1, allocatable_pvs)) {
 		alloc_destroy(ah);
 		return_NULL;
 	}


