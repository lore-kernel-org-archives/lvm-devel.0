From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  8 Jul 2020 09:45:24 +0000 (GMT)
Subject: master - wipe_lv: always zero at least 4K
Message-ID: <20200708094524.033DF385E444@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe78cd4082cb9af10580180d61898fcef93dc624
Commit:        fe78cd4082cb9af10580180d61898fcef93dc624
Parent:        40266faaab07f5578d137f9e400fbc9190edabcd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 8 10:38:36 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 8 11:12:54 2020 +0200

wipe_lv: always zero at least 4K

When zero_sectors passed value like 1 - we could zero only 1 sector.
Reinstantiate we always zero at least 4K block.
---
 lib/metadata/lv_manip.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d96137aff..5956d032c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7642,7 +7642,9 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			if (wp.is_metadata) /* Verbosely notify metadata will not be fully zeroed */
 				log_verbose("Metadata logical volume %s not fully zeroed and may contain stale data.",
 					    display_lvname(lv));
-			zero_sectors = wp.zero_sectors ? : UINT64_C(4096) >> SECTOR_SHIFT;
+			zero_sectors = UINT64_C(4096) >> SECTOR_SHIFT;
+			if (wp.zero_sectors > zero_sectors)
+				zero_sectors = wp.zero_sectors;
 
 			if (zero_sectors > lv->size)
 				zero_sectors = lv->size;


