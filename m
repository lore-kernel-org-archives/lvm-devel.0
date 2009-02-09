From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:22:09 -0500
Subject: [PATCH 21/21] Update lvm_vg_get_attr_list() to use attributes obtained during vg_open().
In-Reply-To: <1234153329-2829-21-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-8-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-9-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-10-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-11-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-12-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-13-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-14-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-15-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-16-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-17-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-18-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-19-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-20-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-21-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-22-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The original lvm_vg_get_attr_list() code used rh->mem, then called
dm_report_free(rh) which released the memory for the attributes.
This patch relies on the change to vg_open(), which reads all vg
attributes and stores them on a list inside struct volume_group.
The list remains valid and the report handle open until vg_close
is called.

TODO: Fix lvm_vg_get_attr_value() to use attribute values obtained
during vg_open.  Probably need to define an lvm_attribute structure.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h          |    2 +-
 lib/report/report.c |   27 +++++----------------------
 2 files changed, 6 insertions(+), 23 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index cc57574..353f5fa 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -80,7 +80,7 @@ const char *lvm_vg_name(const vg_t *vg);
 const char *lvm_lv_name(const lv_t *lv);
 const char *lvm_vg_uuid(vg_t *vg);
 
-int lvm_vg_get_attr_list(vg_t *vg, struct dm_list *list);
+struct dm_list * lvm_vg_get_attr_list(vg_t *vg);
 int lvm_vg_get_attr_value(vg_t *vg, const char *attr_name,
 			  struct dm_report_field_value_type *value);
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 1d219bf..556dca1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1193,29 +1193,9 @@ int report_object(void *handle, struct volume_group *vg,
 /*
  * Get a list of attributes for a vg
  */
-int lvm_vg_get_attr_list(vg_t *vg, struct dm_list *list)
+struct dm_list *lvm_vg_get_attr_list(vg_t *vg)
 {
-	void *rh;
-	report_type_t report_type = VGS;
-
-	dm_list_init(list);
-
-	/*
-	 * Create a report so we can return the headings.
-	 */
-	if (!(rh = report_init(vg->cmd, "all", "", &report_type,
-			       " ", 1, 1, 1, 0, 0, 0))) {
-		stack;
-		return 0;
-	}
-
-	if (!dm_report_get_field_ids(rh, report_type, list)) {
-		dm_report_free(rh);
-		return 0;
-	}
-
-	dm_report_free(rh);
-	return 1;
+	return &vg->attrs;
 }
 
 /*
@@ -1224,6 +1204,9 @@ int lvm_vg_get_attr_list(vg_t *vg, struct dm_list *list)
 int lvm_vg_get_attr_value(vg_t *vg, const char *attr_name,
 			  struct dm_report_field_value_type *value)
 {
+	/*
+	 * FIXME: this should be returning values filled in during vg_open
+	 */
 	void *rh;
 	report_type_t report_type = VGS;
 
-- 
1.6.0.5


