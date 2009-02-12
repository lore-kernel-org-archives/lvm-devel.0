From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 12 Feb 2009 14:30:39 -0500
Subject: [PATCH 10/12] Add lvm_vg_get_attr_list() and lvm_vg_get_attr().
In-Reply-To: <1234467041-21522-10-git-send-email-dwysocha@redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-2-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-3-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-4-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-5-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-6-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-7-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-8-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-9-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1234467041-21522-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For vg attributes, we use dm_report_output_attributes() to read/store
the attributes at lvm_vg_open().  This patch adds two liblvm vg
attribute functions to obtain a full list of attributes as well as
a single attribute:
1. lvm_vg_get_attr_list().  Given a vg, returns a list of attributes
2. lvm_vg_get_attr(). Given a vg and attribute name, returns a single
attribute.

The original lvm_vg_get_attr_list() code used rh->mem, then called
dm_report_free(rh) which released the memory for the attributes.
This patch relies on the change to vg_open(), which reads all vg
attributes and stores them on a list inside struct volume_group.
The list remains valid and the report handle open until vg_close
is called.

TODO: provide an access mode for the attribute to state whether the
attribute is readonly, or read-write.  This may require a specific
liblvm struct.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h          |    3 +++
 lib/report/report.c |   35 ++++++++++++++++++++++++++++++++++-
 2 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index d957db9..92f60fc 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -78,6 +78,9 @@ const char *lvm_pv_name(const pv_t *pv);
 const char *lvm_vg_name(const vg_t *vg);
 const char *lvm_lv_name(const lv_t *lv);
 
+struct dm_list *lvm_vg_get_attr_list(vg_t *vg);
+struct dm_report_attribute_type *lvm_vg_get_attr(vg_t *vg, const char *name);
+
 /*
  * Open volume group 'vg_name' for reading or writing.
  *
diff --git a/lib/report/report.c b/lib/report/report.c
index f603eeb..01ce670 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2002-2004, 2009 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -1190,3 +1190,36 @@ int report_object(void *handle, struct volume_group *vg,
 
 	return dm_report_object(handle, &obj);
 }
+
+/*
+ * Get a list of attributes for a vg
+ */
+struct dm_list *lvm_vg_get_attr_list(vg_t *vg)
+{
+	struct dm_report_attribute_list_type *attr_list;
+
+	dm_list_iterate_items(attr_list, &vg->attrs) {
+		/*
+		 * FIXME: check vg against object.  Currently
+		 * we cannot do this since report_object() allocates
+		 * lvm_report_object on the stack.
+		 */
+		return (&attr_list->attrs);
+	}
+	return NULL;
+}
+
+struct dm_report_attribute_type *lvm_vg_get_attr(vg_t *vg, const char *name)
+{
+	struct dm_report_attribute_type *attr;
+	struct dm_list *attrs;
+
+	if (!(attrs = lvm_vg_get_attr_list(vg))) {
+		return NULL;
+	}
+	dm_list_iterate_items(attr, attrs) {
+		if (!strcmp(attr->name, name))
+			return attr;
+	}
+	return NULL;
+}
-- 
1.6.0.6


