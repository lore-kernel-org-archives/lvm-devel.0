From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 20 Sep 2010 12:49:56 -0400
Subject: [PATCH 17/19] Rename internal vg_get_property to more generic lvm_get_property.
In-Reply-To: <4C91DBDF.7010508@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
	<1284564971-26060-18-git-send-email-dwysocha@redhat.com>
	<4C91D82D.2080302@redhat.com>  <4C91DBDF.7010508@redhat.com>
Message-ID: <1285001396.5111.8.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2010-09-16 at 10:57 +0200, Zdenek Kabelac wrote:
> Dne 16.9.2010 10:41, Zdenek Kabelac napsal(a):
> > Dne 15.9.2010 17:36, Dave Wysochanski napsal(a):
> >>  lib/report/properties.c |    4 ++--
> >>  lib/report/properties.h |    2 +-
> >>  liblvm/lvm_vg.c         |    2 +-
> >>  3 files changed, 4 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/lib/report/properties.c b/lib/report/properties.c
> >> index 0b80593..95da8ab 100644
> >> --- a/lib/report/properties.c
> >> +++ b/lib/report/properties.c
> >> @@ -262,7 +262,7 @@ struct lvm_property_type _properties[] = {
> >>  #undef FIELD
> >>  
> >>  
> >> -int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
> >> +int lvm_get_property(void *obj, struct lvm_property_type *prop)
> > 
> > Hope vg_get_property has been marked as unstable API ?
> > 
> > 
> >>  {
> >>  	struct lvm_property_type *p;
> >>  
> >> @@ -278,7 +278,7 @@ int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
> >>  	}
> >>  
> >>  	*prop = *p;
> >> -	if (!p->get((void *)vg, prop)) {
> >> +	if (!p->get(obj, prop)) {
> >>  		return 0;
> >>  	}
> >>  	return 1;
> >> diff --git a/lib/report/properties.h b/lib/report/properties.h
> >> index 2e1381d..0a13f39 100644
> >> --- a/lib/report/properties.h
> >> +++ b/lib/report/properties.h
> >> @@ -32,6 +32,6 @@ struct lvm_property_type {
> >>  	int (*set) (void *obj, struct lvm_property_type *prop);
> >>  };
> >>  
> >> -int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop);
> >> +int lvm_get_property(void *obj, struct lvm_property_type *prop);
> >>  
> >>  #endif
> >> diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
> >> index 9a72bec..98070dd 100644
> >> --- a/liblvm/lvm_vg.c
> >> +++ b/liblvm/lvm_vg.c
> >> @@ -343,7 +343,7 @@ int lvm_vg_get_property(vg_t vg, const char *name,
> >>  	struct lvm_property_type prop;
> >>  
> >>  	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);
> >> -	if (!vg_get_property(vg, &prop))
> >> +	if (!lvm_get_property((void *)vg, &prop))
> > 
> > No need to add cast to (void*) - it's C not C++...
> > 
> 
> In fact - do we really need this functionality ?? It's quite dangerous to
> allow passing any pointer type to such global API function.
> 
> I would vote for only using separate functionality and using right types and
> right function names - this C++ polymorphism in C code leads to error which
> are hard to catch as compiler will not give any warning about missused typed
> structure pointers.
> 

How about the attached patch in place of this one.  I've left
vg_get_property() alone and added pv_get_property().  Also, I add the
report 'type' to lvm_property_type and then check inside the static
_get_property() function to ensure the correct function is called for
the given 'id' string.


>From 63e74cff2f9db5606b48d64e6ecf53935dd66839 Mon Sep 17 00:00:00 2001
From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 17 Sep 2010 13:16:53 -0400
Subject: [PATCH] Add pv_get_property and create generic internal _get_property function.

We need to use a similar function for pv and lv properties, so just make
a generic _get_property() function that contains most of the required
functionality.  Also, add a check to ensure the field name matches the
object passed in by re-using report_type_t enum.  For pv properties,
the report_type might be either PVS or LABEL.
---
 lib/report/properties.c |   23 +++++++++++++++++++----
 lib/report/properties.h |    3 +++
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 0b80593..52657c0 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -250,11 +250,11 @@ GET_VG_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
 #define FIELD(type, strct, sorttype, head, field, width, fn, id, desc, writeable) \
-	{ #id, writeable, sorttype == STR, { .n_val = 0 }, _ ## id ## _get, _ ## id ## _set },
+	{ type, #id, writeable, sorttype == STR, { .n_val = 0 }, _ ## id ## _get, _ ## id ## _set },
 
 struct lvm_property_type _properties[] = {
 #include "columns.h"
-	{ "", 0, 0, { .n_val = 0 }, _not_implemented, _not_implemented },
+	{ 0, "", 0, 0, { .n_val = 0 }, _not_implemented, _not_implemented },
 };
 
 #undef STR
@@ -262,7 +262,7 @@ struct lvm_property_type _properties[] = {
 #undef FIELD
 
 
-int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
+static int _get_property(void *obj, struct lvm_property_type *prop, report_type_t type)
 {
 	struct lvm_property_type *p;
 
@@ -276,10 +276,25 @@ int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
 		log_errno(EINVAL, "Invalid property name %s", prop->id);
 		return 0;
 	}
+	if (!(p->type & type)) {
+		log_errno(EINVAL, "Property name %s does not match type %d",
+			  prop->id, p->type);
+		return 0;
+	}
 
 	*prop = *p;
-	if (!p->get((void *)vg, prop)) {
+	if (!p->get(obj, prop)) {
 		return 0;
 	}
 	return 1;
 }
+
+int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
+{
+	return _get_property(vg, prop, VGS);
+}
+
+int pv_get_property(struct physical_volume *pv, struct lvm_property_type *prop)
+{
+	return _get_property(pv, prop, PVS | LABEL);
+}
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 2e1381d..1a1a439 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -17,10 +17,12 @@
 #include "libdevmapper.h"
 #include "lvm-types.h"
 #include "metadata.h"
+#include "report.h"
 
 #define LVM_PROPERTY_NAME_LEN DM_REPORT_FIELD_TYPE_ID_LEN
 
 struct lvm_property_type {
+	report_type_t type;
 	char id[LVM_PROPERTY_NAME_LEN];
 	unsigned is_writeable;
 	unsigned is_string;
@@ -33,5 +35,6 @@ struct lvm_property_type {
 };
 
 int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop);
+int pv_get_property(struct physical_volume *pv, struct lvm_property_type *prop);
 
 #endif
-- 
1.7.2.2




