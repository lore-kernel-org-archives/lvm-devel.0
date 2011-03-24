From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 24 Mar 2011 12:16:34 +0100
Subject: [PATCH 1/4] Reading of unitialized memory
In-Reply-To: <cover.1300965223.git.zkabelac@redhat.com>
References: <cover.1300965223.git.zkabelac@redhat.com>
Message-ID: <3203b388b56009070e7de15bde71d0ded8d9a91f.1300965223.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is rather hint fix just for reading of unknown memory.

Could be reached via few our test cases:

==11501== Invalid read of size 8
==11501==    at 0x49B2E0: _area_length (import-extents.c:204)
==11501==    by 0x49B40C: _read_linear (import-extents.c:222)
==11501==    by 0x49B952: _build_segments (import-extents.c:323)
==11501==    by 0x49B9A0: _build_all_segments (import-extents.c:334)
==11501==    by 0x49BB4C: import_extents (import-extents.c:364)
==11501==    by 0x497655: _format1_vg_read (format1.c:217)
==11501==    by 0x47E43E: _vg_read (metadata.c:2901)

cut from t-vgcvgbackup-usage.sh
--
pvcreate -M1 $(cat DEVICES)
vgcreate -M1 -c n $vg $(cat DEVICES)
lvcreate -l1 -n $lv1 $vg $dev1
--

Idea of the fix is rather defensive - to allocate one extra element
to 'map' array which is then used in _area_length().

lv->le_count == 1 - thus allocated 'map' array allows to access only
element [0] - but the loop in _area_lenght start directly with:
 len++ (== 1) - thus accessing element behind the allocated array.

As I'm not familiar with the LVM1 code so there is potentialy better fix.
My patch is rather hint where is the bug - and avoids read of random
memory - but does not fix algorithmic bug here - do we even care about
format 1 ?

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format1/import-extents.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
index 99723ee..dc12776 100644
--- a/lib/format1/import-extents.c
+++ b/lib/format1/import-extents.c
@@ -64,7 +64,7 @@ static struct dm_hash_table *_create_lv_maps(struct dm_pool *mem,
 
 		lvm->lv = ll->lv;
 		if (!(lvm->map = dm_pool_zalloc(mem, sizeof(*lvm->map)
-					     * ll->lv->le_count)))
+					     * (ll->lv->le_count + 1))))
 			goto_bad;
 
 		if (!dm_hash_insert(maps, ll->lv->name, lvm))
-- 
1.7.4.1


