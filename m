From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 18 Aug 2010 09:51:58 -0400
Subject: [PATCH 07/11] Add implementation for vg_mda_*_get functions.
In-Reply-To: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1282139522-31240-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add 'get' function implementation for vg_mda_count, vg_mda_used_count,
vg_mda_free, vg_mda_size.  These are read-only properties so the 'set'
functions are defined to the _not_implemented function.

Multiply SECTOR_SIZE to vg_mda_size to return the value in bytes.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |   35 +++++++++++++++++++++++++++++++----
 1 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 9f06d9e..879f849 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -139,13 +139,40 @@ static int _not_implemented(void *obj, struct lvm_property_type *prop)
 #define _vg_seqno_set _not_implemented
 #define _vg_tags_get _not_implemented
 #define _vg_tags_set _not_implemented
-#define _vg_mda_count_get _not_implemented
+static int _vg_mda_count_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg_mda_count(vg);
+	return 1;
+}
 #define _vg_mda_count_set _not_implemented
-#define _vg_mda_used_count_get _not_implemented
+
+static int _vg_mda_used_count_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg_mda_used_count(vg);
+	return 1;
+}
 #define _vg_mda_used_count_set _not_implemented
-#define _vg_mda_free_get _not_implemented
+
+static int _vg_mda_free_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg_mda_free(vg);
+	return 1;
+}
 #define _vg_mda_free_set _not_implemented
-#define _vg_mda_size_get _not_implemented
+
+static int _vg_mda_size_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = SECTOR_SIZE * vg_mda_size(vg);
+	return 1;
+}
 #define _vg_mda_size_set _not_implemented
 
 static int _vg_mda_copies_get (void *obj, struct lvm_property_type *prop)
-- 
1.7.2.1


