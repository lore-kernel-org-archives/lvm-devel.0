From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:15 +0200
Subject: [PATCH 08/30] Ensure first is not NULL
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <a1f0ffae5f0040b65da905155599c68712b800f5.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang Logic error	Dereference of null pointer

For empty lists make sure the NULL first pointer is not dereferenced.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format1/format1.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 0dcec05..0efde31 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -103,7 +103,7 @@ static int _check_vgs(struct dm_list *pvs, struct volume_group *vg)
 	}
 
 	/* On entry to fn, list known to be non-empty */
-	if (pv_count != first->vgd.pv_cur) {
+	if (first && (pv_count != first->vgd.pv_cur)) {
 		log_error("%d PV(s) found for VG %s: expected %d",
 			  pv_count, first->pvd.vg_name, first->vgd.pv_cur);
 		vg->status |= PARTIAL_VG;
-- 
1.7.3.1


