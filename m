From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:54 +0000 (GMT)
Subject: master - wipe_lv: drop label_scan_invalidate on error path
Message-ID: <20201002202754.7C96C3945C25@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7396f1cfee0399237aee1ed41f5930746ee31716
Commit:        7396f1cfee0399237aee1ed41f5930746ee31716
Parent:        b44db5d1a7ecc2e8e3cef0852c4397b64ddf0a09
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 19:26:58 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 21:02:04 2020 +0200

wipe_lv: drop label_scan_invalidate on error path

Since dev_set_bytes() now closes  dev on error path itself,
remove this unneeded call now (introduced few commits back
in history thus removing comment from WHATS_NEW)
---
 WHATS_NEW               | 1 -
 lib/metadata/lv_manip.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a93a61b32..d4cf61d71 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -20,7 +20,6 @@ Version 2.03.11 -
   Fix 64bit math when calculation cachevol size.
   Preserve uint32_t for seqno handling.
   Switch from mmap to plain read when loading regular files.
-  Fix missing device closing on wiping error path.
   Update lvmvdo man page and better explain DISCARD usage.
 
 Version 2.03.10 - 09th August 2020
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a907130ff..f61705909 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7706,7 +7706,6 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			    display_lvname(lv), wp.zero_value);
 
 		if (!dev_set_bytes(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp.zero_value)) {
-			label_scan_invalidate(dev);
 			log_error("Failed to initialize %s of logical volume %s with value %d.",
 				  display_size(lv->vg->cmd, zero_sectors),
 				  display_lvname(lv), wp.zero_value);


