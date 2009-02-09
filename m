From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:22:07 -0500
Subject: [PATCH 19/21] Update lvm_vg_open() to read and store the list of vg attributes.
In-Reply-To: <1234153329-2829-19-git-send-email-dwysocha@redhat.com>
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
Message-ID: <1234153329-2829-20-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The original lvm_vg_get_attr_list() code used rh->mem, then called
dm_report_free(rh) which released the memory for the attributes.
For obvious reasons this won't work.

This patch is basically the original lvm_vg_get_attr_list() code moved
into lvm_vg_open().  We read all vg attributes and store them on a list
inside struct volume_group.  The list remains valid and the report handle
open until vg_close is called where we call dm_report_free().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.c                       |   27 +++++++++++++++++++--------
 lib/metadata/metadata-exported.h |    6 ++++++
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/lib/lvm2.c b/lib/lvm2.c
index e6b1a8e..84546ba 100644
--- a/lib/lvm2.c
+++ b/lib/lvm2.c
@@ -64,6 +64,7 @@ vg_t *lvm_vg_open(lvm_handle_t libh, const char *name_or_uuid, mode_t mode)
 	int found_id = 0;
 	uint32_t flags;
 	const char *vg_name;
+	report_type_t report_type = VGS;
 	
 	if ((mode & O_ACCMODE) == O_RDONLY) {
 		flags = 0;
@@ -108,17 +109,26 @@ vg_t *lvm_vg_open(lvm_handle_t libh, const char *name_or_uuid, mode_t mode)
 	vg->mode = mode;
 
 	/*
-	 * Something went wrong trying the uuid.
-	 * Attempt the read assuming we have a vgname.
+	 * Fill in all attributes
 	 */
-	vg = vg_read(libh->cmd, name_or_uuid, NULL, flags);
-	if (!vg_read_error(vg)) {
-		vg->mode = mode;
-		return vg;
+	dm_list_init(&vg->attrs);
+
+	/*
+	 * Create a report so we can return the field ids / attribute names
+	 */
+	if (!(vg->rh = report_init(vg->cmd, "all", "", &report_type,
+				   " ", 1, 1, 1, 0, 0, 0))) {
+		stack;
+		/* FIXME: set errno */
+		return NULL;
 	}
 
-	/* FIXME: set errno */
-	return NULL;
+	if (!dm_report_get_field_ids(vg->rh, report_type, &vg->attrs)) {
+		dm_report_free(vg->rh);
+		/* FIXME: set errno */
+		return NULL;
+	}
+	return vg;
 }
 
 /*
@@ -128,6 +138,7 @@ vg_t *lvm_vg_open(lvm_handle_t libh, const char *name_or_uuid, mode_t mode)
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
1.6.0.5


