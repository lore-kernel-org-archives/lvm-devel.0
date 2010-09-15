From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:36:09 -0400
Subject: [PATCH 17/19] Rename internal vg_get_property to more generic lvm_get_property.
In-Reply-To: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284564971-26060-18-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We need to use a similar function for pv and lv properties, so just make
the internal library function take a void *.  This makes the interface more
consistent as the lvm_property_type struct contains 'get' and 'set'
methods taking a void *.  The disambiguation occurs when looking up the
field name - see columns.h and the requirement that field names be unique.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |    4 ++--
 lib/report/properties.h |    2 +-
 liblvm/lvm_vg.c         |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 0b80593..95da8ab 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -262,7 +262,7 @@ struct lvm_property_type _properties[] = {
 #undef FIELD
 
 
-int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
+int lvm_get_property(void *obj, struct lvm_property_type *prop)
 {
 	struct lvm_property_type *p;
 
@@ -278,7 +278,7 @@ int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
 	}
 
 	*prop = *p;
-	if (!p->get((void *)vg, prop)) {
+	if (!p->get(obj, prop)) {
 		return 0;
 	}
 	return 1;
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 2e1381d..0a13f39 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -32,6 +32,6 @@ struct lvm_property_type {
 	int (*set) (void *obj, struct lvm_property_type *prop);
 };
 
-int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop);
+int lvm_get_property(void *obj, struct lvm_property_type *prop);
 
 #endif
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 9a72bec..98070dd 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -343,7 +343,7 @@ int lvm_vg_get_property(vg_t vg, const char *name,
 	struct lvm_property_type prop;
 
 	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);
-	if (!vg_get_property(vg, &prop))
+	if (!lvm_get_property((void *)vg, &prop))
 		return -1;
 	value->is_writeable = prop.is_writeable;
 	value->is_string = prop.is_string;
-- 
1.7.2.1


