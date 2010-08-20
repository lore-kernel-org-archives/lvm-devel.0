From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2010 13:02:40 -0000
Subject: LVM2/lib/report properties.c
Message-ID: <20100820130240.24771.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-08-20 13:02:39

Modified files:
	lib/report     : properties.c 

Log message:
	Define GET_NUM_PROPERTY_FN macro to simplify numeric property 'get' functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/report/properties.c	2010/08/20 12:45:09	1.2
+++ LVM2/lib/report/properties.c	2010/08/20 13:02:39	1.3
@@ -20,6 +20,15 @@
 #include "lvm-types.h"
 #include "metadata.h"
 
+#define GET_NUM_PROPERTY_FN(NAME, VALUE) \
+static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
+{ \
+	struct volume_group *vg = (struct volume_group *)obj; \
+\
+	prop->v.n_val = VALUE; \
+	return 1; \
+}
+
 static int _not_implemented(void *obj, struct lvm_property_type *prop)
 {
 	log_errno(ENOSYS, "Function not implemented");


