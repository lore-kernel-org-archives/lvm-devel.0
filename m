From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2009 23:40:06 -0000
Subject: LVM2/liblvm .exported_symbols Makefile.in lvm. ...
Message-ID: <20090723234006.21139.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-23 23:40:05

Modified files:
	liblvm         : .exported_symbols Makefile.in lvm.h lvm_vg.c 
Added files:
	liblvm         : lvm_lv.c lvm_pv.c 

Log message:
	Add lvm_{pv|vg|lv}_get_{uuid|name}.
	
	Caller must free the memory of the uuid / name returned.
	This may not be the best memory management policy since it may lead to
	memory leaks if the caller has code like this:
	if (!lvm_vg_get_name(vg))
	
	Maybe we don't care - if we do we can use pools tied to handles later
	or some other scheme.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Thomas Woerner <twoerner@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

/cvs/lvm2/LVM2/liblvm/lvm_lv.c,v  -->  standard output
revision 1.1
--- LVM2/liblvm/lvm_lv.c
+++ -	2009-07-23 23:40:06.280566000 +0000
@@ -0,0 +1,40 @@
+/*
+ * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "lvm.h"
+#include "metadata-exported.h"
+#include "lvm-string.h"
+
+char *lvm_lv_get_uuid(const lv_t *lv)
+{
+	char uuid[64] __attribute((aligned(8)));
+
+	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid))) {
+		log_error("Internal error converting uuid");
+		return NULL;
+	}
+	return strndup((const char *)uuid, 64);
+}
+
+char *lvm_lv_get_name(const lv_t *lv)
+{
+	char *name;
+
+	name = malloc(NAME_LEN + 1);
+	strncpy(name, (const char *)lv->name, NAME_LEN);
+	name[NAME_LEN] = '\0';
+	return name;
+}
+
/cvs/lvm2/LVM2/liblvm/lvm_pv.c,v  -->  standard output
revision 1.1
--- LVM2/liblvm/lvm_pv.c
+++ -	2009-07-23 23:40:06.447089000 +0000
@@ -0,0 +1,40 @@
+/*
+ * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "lvm.h"
+#include "metadata-exported.h"
+#include "lvm-string.h"
+
+char *lvm_pv_get_uuid(const pv_t *pv)
+{
+	char uuid[64] __attribute((aligned(8)));
+
+	if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
+		log_error("Internal error converting uuid");
+		return NULL;
+	}
+	return strndup((const char *)uuid, 64);
+}
+
+char *lvm_pv_get_name(const pv_t *pv)
+{
+	char *name;
+
+	name = malloc(NAME_LEN + 1);
+	strncpy(name, (const char *)pv_dev_name(pv), NAME_LEN);
+	name[NAME_LEN] = '\0';
+	return name;
+}
+
--- LVM2/liblvm/.exported_symbols	2009/07/23 23:39:02	1.5
+++ LVM2/liblvm/.exported_symbols	2009/07/23 23:40:05	1.6
@@ -1,6 +1,12 @@
 lvm_create
 lvm_destroy
 lvm_reload_config
+lvm_pv_get_uuid
+lvm_vg_get_uuid
+lvm_lv_get_uuid
+lvm_pv_get_name
+lvm_vg_get_name
+lvm_lv_get_name
 lvm_vg_create
 lvm_vg_extend
 lvm_vg_set_extent_size
--- LVM2/liblvm/Makefile.in	2009/07/22 21:09:14	1.10
+++ LVM2/liblvm/Makefile.in	2009/07/23 23:40:05	1.11
@@ -18,6 +18,8 @@
 
 SOURCES =\
 	lvm_base.c \
+	lvm_lv.c \
+	lvm_pv.c \
 	lvm_vg.c
 
 LIB_NAME = liblvm2app
--- LVM2/liblvm/lvm.h	2009/07/23 23:39:02	1.9
+++ LVM2/liblvm/lvm.h	2009/07/23 23:40:05	1.10
@@ -198,6 +198,22 @@
 int lvm_vg_remove(vg_t *vg);
 
 /**
+ * Get the current name or uuid of a PV, VG, or LV.
+ *
+ * Returns a copy of the current name or uuid for the given PV,
+ * VG, or LV.
+ *
+ * Memory is allocated using malloc() and caller must free the memory
+ * using free().
+ */
+char *lvm_pv_get_uuid(const pv_t *pv);
+char *lvm_vg_get_uuid(const vg_t *vg);
+char *lvm_lv_get_uuid(const lv_t *lv);
+char *lvm_pv_get_name(const pv_t *pv);
+char *lvm_vg_get_name(const vg_t *vg);
+char *lvm_lv_get_name(const lv_t *lv);
+
+/**
  * Close a VG opened with lvm_vg_create
  *
  * This API releases a VG handle and any resources associated with the handle.
--- LVM2/liblvm/lvm_vg.c	2009/07/23 23:39:02	1.5
+++ LVM2/liblvm/lvm_vg.c	2009/07/23 23:40:05	1.6
@@ -21,6 +21,7 @@
 #include "metadata-exported.h"
 #include "archiver.h"
 #include "locking.h"
+#include "lvm-string.h"
 
 vg_t *lvm_vg_create(lvm_t libh, const char *vg_name)
 {
@@ -166,3 +167,24 @@
 	}
 	return list;
 }
+
+char *lvm_vg_get_uuid(const vg_t *vg)
+{
+	char uuid[64] __attribute((aligned(8)));
+
+	if (!id_write_format(&vg->id, uuid, sizeof(uuid))) {
+		log_error("Internal error converting uuid");
+		return NULL;
+	}
+	return strndup((const char *)uuid, 64);
+}
+
+char *lvm_vg_get_name(const vg_t *vg)
+{
+	char *name;
+
+	name = malloc(NAME_LEN + 1);
+	strncpy(name, (const char *)vg->name, NAME_LEN);
+	name[NAME_LEN] = '\0';
+	return name;
+}


