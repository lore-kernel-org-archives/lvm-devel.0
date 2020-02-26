From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 Feb 2020 07:30:16 -0500
Subject: master - vdo: fix slab size bits calculation
Message-ID: <202002261230.01QCUGbb001044@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d02d7bc560ef27d2a0e66d40f96519379d320735
Commit:        d02d7bc560ef27d2a0e66d40f96519379d320735
Parent:        84eab461c843e2018b6ff73a9af8140e27cde391
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 21 11:59:29 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 25 17:43:16 2020 +0100

vdo: fix slab size bits calculation

When formating VDO volume, the calculated amound of bits
for 'vdoformat --slab-bits' parameter was shifted by 2 bits
(calculated size was making 2MiB vdo_slab_size_mb value appear like if
user would be specifying only 512KiB)

Fixed by properly converting internal size_mb value to KiB.
---
 lib/metadata/vdo_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 335e7dd..7862682 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -248,7 +248,7 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 		args++;
 	}
 
-	slabbits = 31 - clz(vtp->slab_size_mb / DM_VDO_BLOCK_SIZE * 512);
+	slabbits = 31 - clz(vtp->slab_size_mb / DM_VDO_BLOCK_SIZE * 2 * 1024);  /* to KiB / block_size */
 	log_debug("Slab size %s converted to %u bits.",
 		  display_size(data_lv->vg->cmd, vtp->slab_size_mb * UINT64_C(2 * 1024)), slabbits);
 	if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--slab-bits=%u", slabbits) < 0)



