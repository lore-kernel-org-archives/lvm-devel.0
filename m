From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 18 Aug 2010 09:51:57 -0400
Subject: [PATCH 06/11] Add _vg_mda_copies_get and _vg_mda_copies_set.
In-Reply-To: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1282139522-31240-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add the 'get' / 'set' functions for vg_mda_copies property.
Since vg_mda_copies is a field that can be changed (see vgchange, etc),
we add a 'set' function here and change the '0' to a '1' in the columns.h
file.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/columns.h    |    2 +-
 lib/report/properties.c |   16 ++++++++++++++--
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 65d322b..4d75ba3 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -118,7 +118,7 @@ FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, vg_mda_count, "Number of metadata a
 FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, vg_mda_used_count, "Number of metadata areas in use on this VG.", 0)
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, vg_mda_free, "Free metadata area space for this VG in current units.", 0)
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, vg_mda_size, "Size of smallest metadata area for this VG in current units.", 0)
-FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 0)
+FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 1)
 
 FIELD(SEGS, seg, STR, "Type", list, 4, segtype, segtype, "Type of LV segment.", 0)
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, stripes, "Number of stripes or mirror legs.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index a914406..9f06d9e 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -147,8 +147,20 @@ static int _not_implemented(void *obj, struct lvm_property_type *prop)
 #define _vg_mda_free_set _not_implemented
 #define _vg_mda_size_get _not_implemented
 #define _vg_mda_size_set _not_implemented
-#define _vg_mda_copies_get _not_implemented
-#define _vg_mda_copies_set _not_implemented
+
+static int _vg_mda_copies_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg_mda_copies(vg);
+	return 1;
+}
+
+static int _vg_mda_copies_set (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+	return vg_set_mda_copies(vg, prop->v.n_val);
+}
 
 /* LVSEG */
 #define _segtype_get _not_implemented
-- 
1.7.2.1


