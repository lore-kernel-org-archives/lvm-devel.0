From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Sep 2020 21:46:45 +0000 (GMT)
Subject: master - vdo: drop unnecessary tabulator from metadata output
Message-ID: <20200922214645.E84B539450F9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e08a0421a374164fe49276d0bf676989bf7aea14
Commit:        e08a0421a374164fe49276d0bf676989bf7aea14
Parent:        5bc66532c70ea2e820b92eb65e0dd21f8caa3394
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 20:38:07 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 23:25:16 2020 +0200

vdo: drop unnecessary tabulator from metadata output

---
 lib/vdo/vdo.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index 01d95f7f7..ab6d00825 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -302,10 +302,10 @@ static int _vdo_pool_text_export(const struct lv_segment *seg, struct formatter
 	const struct dm_vdo_target_params *vtp = &seg->vdo_params;
 
 	outf(f, "data = \"%s\"", seg_lv(seg, 0)->name);
-	outsize(f, seg->vdo_pool_header_size, "header_size = %u\t",
+	outsize(f, seg->vdo_pool_header_size, "header_size = %u",
 		seg->vdo_pool_header_size);
 	outsize(f, seg->vdo_pool_virtual_extents * (uint64_t) seg->lv->vg->extent_size,
-		"virtual_extents = %u\t", seg->vdo_pool_virtual_extents);
+		"virtual_extents = %u", seg->vdo_pool_virtual_extents);
 
 	outnl(f);
 


