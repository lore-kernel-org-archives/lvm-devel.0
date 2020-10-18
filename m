From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:30 +0000 (GMT)
Subject: stable-2.02 - wipe_lv: always zero at least 4K
Message-ID: <20201018210230.6C45C3857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c746f153e351a806592554cf1d90ddb03879933
Commit:        9c746f153e351a806592554cf1d90ddb03879933
Parent:        8ee2479dd0547ee6451da5b3e2ffca2f808c09a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 8 10:38:36 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:27:51 2020 +0200

wipe_lv: always zero at least 4K

When zero_sectors passed value like 1 - we could zero only 1 sector.
Reinstantiate we always zero at least 4K block.
---
 lib/metadata/lv_manip.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0e58d4fa9..660e742dd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7248,7 +7248,9 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			if (wp.is_metadata) /* Verbosely notify metadata will not be fully zeroed */
 				log_verbose("Metadata logical volume %s not fully zeroed and may contain stale data.",
 					    display_lvname(lv));
-			zero_sectors = wp.zero_sectors ? : UINT64_C(4096) >> SECTOR_SHIFT;
+			zero_sectors = UINT64_C(4096) >> SECTOR_SHIFT;
+			if (wp.zero_sectors > zero_sectors)
+				zero_sectors = wp.zero_sectors;
 
 			if (zero_sectors > lv->size)
 				zero_sectors = lv->size;


