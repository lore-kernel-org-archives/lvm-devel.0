From: Milan Broz <mbroz@redhat.com>
Date: Mon, 14 Jun 2010 18:20:07 +0200
Subject: [PATCH] Allow use headers in C++.
Message-ID: <1276532407-15147-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove C++ private keyword from header.
Add extern C definition for libdevmapper and lvm2app.
---
 libdm/libdevmapper.h |   13 ++++++++++---
 libdm/libdm-report.c |    4 ++--
 liblvm/lvm2app.h     |    6 ++++++
 3 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0b67a0f..7c72cf7 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -29,6 +29,10 @@
 #include <stdlib.h>
 #include <stdio.h>
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 /*****************************************************************
  * The first section of this file provides direct access to the
  * individual device-mapper ioctls.  Since it is quite laborious to
@@ -1022,7 +1026,7 @@ struct dm_report_field_type {
 	const char heading[32];	/* string printed in header */
 	int (*report_fn)(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field, const void *data,
-			 void *private);
+			 void *private_data);
 	const char *desc;	/* description of the field */
 };
 
@@ -1044,7 +1048,7 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 				 const char *output_separator,
 				 uint32_t output_flags,
 				 const char *sort_keys,
-				 void *private);
+				 void *private_data);
 int dm_report_object(struct dm_report *rh, void *object);
 int dm_report_output(struct dm_report *rh);
 void dm_report_free(struct dm_report *rh);
@@ -1163,4 +1167,7 @@ int dm_udev_wait(uint32_t cookie);
 
 #define DM_DEV_DIR_UMASK 0022
 
+#ifdef __cplusplus
+}
+#endif
 #endif				/* LIB_DEVICE_MAPPER_H */
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index e13115a..2b044b5 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -566,7 +566,7 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 				 const char *output_separator,
 				 uint32_t output_flags,
 				 const char *sort_keys,
-				 void *private)
+				 void *private_data)
 {
 	struct dm_report *rh;
 	const struct dm_report_object_type *type;
@@ -588,7 +588,7 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 	rh->separator = output_separator;
 	rh->fields = fields;
 	rh->types = types;
-	rh->private = private;
+	rh->private = private_data;
 
 	rh->flags |= output_flags & DM_REPORT_OUTPUT_MASK;
 
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 09455da..05f804f 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -18,6 +18,9 @@
 
 #include <stdint.h>
 
+#ifdef __cplusplus
+extern "C" {
+#endif
 
 /******************************** WARNING ***********************************
  *
@@ -1194,4 +1197,7 @@ uint64_t lvm_pv_get_free(const pv_t pv);
  */
 int lvm_pv_resize(const pv_t pv, uint64_t new_size);
 
+#ifdef __cplusplus
+}
+#endif
 #endif /* _LIB_LVM2APP_H */
-- 
1.7.1


