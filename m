From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:48 +0100
Subject: [PATCH 16/23] Remove check for vg != NULL
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <7aec002f1922f5c146bb739fda55e9803ab2f2fa.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Checking for vg being != NULL in this place is not needed.
We are derefercing vg already in this function above this code line.
Also the function _read_pv is always called with 'vg' assigned some
valid pointer.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/import_vsn1.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 5a2d664..083c8ee 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -257,14 +257,12 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		log_verbose("Fixing up missing size (%s) "
 			    "for PV %s", display_size(fid->fmt->cmd, pv->size),
 			    pv_dev_name(pv));
-		if (vg) {
-			size = pv->pe_count * (uint64_t) vg->extent_size +
-			       pv->pe_start;
-			if (size > pv->size)
-				log_warn("WARNING: Physical Volume %s is too "
-					 "large for underlying device",
-					 pv_dev_name(pv));
-		}
+		size = pv->pe_count * (uint64_t) vg->extent_size +
+			pv->pe_start;
+		if (size > pv->size)
+			log_warn("WARNING: Physical Volume %s is too "
+				 "large for underlying device",
+				 pv_dev_name(pv));
 	}
 
 	if (!alloc_pv_segment_whole_pv(mem, pv))
-- 
1.7.3.4


