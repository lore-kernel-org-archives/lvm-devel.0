From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 12 Jul 2013 22:46:58 +0000 (UTC)
Subject: master - lvm2api: Add missing files from prev commit.
Message-ID: <20130712224658.85EAF61169@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b213492f8e690acb163b833eadfdb25501d8f26
Commit:        5b213492f8e690acb163b833eadfdb25501d8f26
Parent:        79eb40a2c8249e9e425f5950d1e9ec275da2d121
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jul 12 18:42:48 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jul 12 17:46:15 2013 -0500

lvm2api: Add missing files from prev commit.

Missing files for commit 0a048d5274612049467a3defd13de7aca2419137

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm_prop.c        |   44 ++++++++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_prop.h        |   35 +++++++++++++++++++++++++++++++++++
 liblvm/lvm_prop_fields.h |   15 +++++++++++++++
 3 files changed, 94 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm_prop.c b/liblvm/lvm_prop.c
new file mode 100644
index 0000000..e25f03b
--- /dev/null
+++ b/liblvm/lvm_prop.c
@@ -0,0 +1,44 @@
+/*
+ * Copyright (C) 2013 Red Hat, Inc. All rights reserved.
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
+#include "lvm_prop.h"
+#include "libdevmapper.h"
+#include "lvm-types.h"
+#include "metadata.h"
+
+/* lv create parameters */
+GET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
+SET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
+
+struct lvm_property_type _lib_properties[] = {
+#include "lvm_prop_fields.h"
+	{ 0, "", 0, 0, 0, { .integer = 0 }, prop_not_implemented_get,
+			prop_not_implemented_set },
+};
+
+#undef STR
+#undef NUM
+#undef FIELD
+
+int lv_create_param_get_property(const struct lvcreate_params *lvcp,
+		struct lvm_property_type *prop)
+{
+	return prop_get_property(_lib_properties, lvcp, prop, LV_CREATE_PARAMS);
+}
+
+int lv_create_param_set_property(struct lvcreate_params *lvcp,
+		    struct lvm_property_type *prop)
+{
+	return prop_set_property(_lib_properties, lvcp, prop, LV_CREATE_PARAMS);
+}
diff --git a/liblvm/lvm_prop.h b/liblvm/lvm_prop.h
new file mode 100644
index 0000000..bedc078
--- /dev/null
+++ b/liblvm/lvm_prop.h
@@ -0,0 +1,35 @@
+/*
+ * Copyright (C) 2013 Red Hat, Inc. All rights reserved.
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
+#include "prop_common.h"
+
+#ifndef _LIB_LVM_PROP_H
+#define _LIB_LVM_PROP_H
+
+typedef struct lvcreate_params type_lvcreate_params;
+
+#define LV_CREATE_PARAMS 1
+
+#define GET_LVCREATEPARAMS_NUM_PROPERTY_FN(NAME, VALUE)\
+	GET_NUM_PROPERTY_FN(NAME, VALUE, lvcreate_params, lvcp)
+
+#define SET_LVCREATEPARAMS_NUM_PROPERTY_FN(NAME, VALUE) \
+	SET_NUM_PROPERTY(NAME, VALUE, lvcreate_params, lvcp)
+
+int lv_create_param_get_property(const struct lvcreate_params *lvcp,
+		struct lvm_property_type *prop);
+
+int lv_create_param_set_property(struct lvcreate_params *lvcp,
+		    struct lvm_property_type *prop);
+
+#endif
diff --git a/liblvm/lvm_prop_fields.h b/liblvm/lvm_prop_fields.h
new file mode 100644
index 0000000..99c322d
--- /dev/null
+++ b/liblvm/lvm_prop_fields.h
@@ -0,0 +1,15 @@
+/*
+ * Copyright (C) 2013 Red Hat, Inc. All rights reserved.
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
+FIELD(LV_CREATE_PARAMS, lvcreate_params, NUM, "skip_zero", zero, 2, uint32, skip_zero, "Skip zeroing on lv creation", 1)


