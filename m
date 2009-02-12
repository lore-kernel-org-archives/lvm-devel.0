From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 12 Feb 2009 14:30:38 -0500
Subject: [PATCH 09/12] Update lvm_vg_open() to read and store the list of vg attributes.
In-Reply-To: <1234467041-21522-9-git-send-email-dwysocha@redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-2-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-3-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-4-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-5-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-6-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-7-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-8-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-9-git-send-email-dwysocha@redhat.com>
Message-ID: <1234467041-21522-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We read all vg attributes and store them on a list inside struct
volume_group.  The list remains valid and the report handle
open until vg_close is called where we call dm_report_free().

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.c                       |   42 +++++++++++++++++++++++++++++++++++++-
 lib/metadata/metadata-exported.h |    6 +++++
 2 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/lib/lvm2.c b/lib/lvm2.c
index f48b451..c8c65ab 100644
--- a/lib/lvm2.c
+++ b/lib/lvm2.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -41,6 +41,36 @@ char *lvm_strerror(lvm_handle_t libh)
 	return strerror(libh->lvm_errno);
 }
 
+static int _vg_attribute_init(vg_t *vg)
+{
+	report_type_t report_type = VGS;
+
+	dm_list_init(&vg->attrs);
+
+	/*
+	 * Create a report so we can return the field ids / attribute names
+	 */
+	if (!(vg->rh = report_init(vg->cmd, "all", "", &report_type,
+				   " ", 1, 1, 1, 0, 0, 0))) {
+		stack;
+		/* FIXME: set errno */
+		return 0;
+	}
+
+	if (!report_object(vg->rh, vg, NULL, NULL, NULL, NULL)) {
+		stack;
+		return 0;
+	}
+
+	if (!dm_report_output_attributes(vg->rh, &vg->attrs)) {
+		dm_report_free(vg->rh);
+		/* FIXME: set errno */
+		return 0;
+	}
+	return 1;
+}
+
+
 /*
  * Open / read a VG.
  * FIXME: Only read access allowed.
@@ -62,6 +92,15 @@ vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode)
 		return NULL;
 	}
 	vg->mode = mode;
+
+	/*
+	 * Fill in all attributes
+	 */
+	if (!_vg_attribute_init(vg)) {
+		/* FIXME: set errno */
+		return NULL;
+	}
+
 	return vg;
 }
 
@@ -72,6 +111,7 @@ vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode)
  */
 void lvm_vg_close(vg_t *vg)
 {
+	dm_report_free(vg->rh);
 	if (vgname_is_locked(vg->name))
 		unlock_vg(vg->cmd, vg->name);
 }
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3063abb..c1d771b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -261,6 +261,12 @@ struct volume_group {
 	 * 0 for success else appropriate FAILURE_* bits set.
 	 */
 	uint32_t read_status;
+
+	/*
+	 * Store all fields of a VG report here, the vg attributes.
+	 */
+	struct dm_list attrs;
+	void *rh;
 };
 
 /* There will be one area for each stripe */
-- 
1.6.0.6


