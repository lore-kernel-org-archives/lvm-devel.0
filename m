From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 18 Aug 2010 09:52:00 -0400
Subject: [PATCH 09/11] Add 'get' functions for a few vg string fields, vg_name and vg_fmt.
In-Reply-To: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1282139522-31240-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add _vg_name_get and _vg_fmt_get functions.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index d21c2b0..027dafc 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -105,11 +105,26 @@ static int _not_implemented(void *obj, struct lvm_property_type *prop)
 #define _modules_set _not_implemented
 
 /* VG */
-#define _vg_fmt_get _not_implemented
+static int _vg_fmt_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	if (!vg->fid || !vg->fid->fmt)
+		prop->v.s_val = NULL;
+	else
+		prop->v.s_val = (char *)vg->fid->fmt->name;
+	return 1;
+}
 #define _vg_fmt_set _not_implemented
 #define _vg_uuid_get _not_implemented
 #define _vg_uuid_set _not_implemented
-#define _vg_name_get _not_implemented
+static int _vg_name_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.s_val = (char *)vg->name;
+	return 1;
+}
 #define _vg_name_set _not_implemented
 #define _vg_attr_get _not_implemented
 #define _vg_attr_set _not_implemented
-- 
1.7.2.1


