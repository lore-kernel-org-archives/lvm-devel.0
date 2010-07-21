From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 21 Jul 2010 09:56:13 -0400
Subject: [PATCH 2/4] Add report_value() function to return a value of a report field.
In-Reply-To: <1279720575-27485-2-git-send-email-dwysocha@redhat.com>
References: <1279720575-27485-1-git-send-email-dwysocha@redhat.com>
	<1279720575-27485-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1279720575-27485-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Call into dm_report_get_field_value() to query the value of a single
field in a report.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/report.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/report/report.h |    7 +++++
 2 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index b3f6544..8eb919b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1299,3 +1299,68 @@ int report_object(void *handle, struct volume_group *vg,
 
 	return dm_report_object(handle, &obj);
 }
+
+int report_value(struct volume_group *vg,
+		 struct logical_volume *lv,
+		 struct physical_volume *pv,
+		 struct lv_segment *seg,
+		 struct pv_segment *pvseg,
+		 const char *field_id,
+		 struct dm_report_field_value_type *value)
+{
+	void *rh;
+	report_type_t report_type = VGS;
+	struct dm_pool *mem;
+	struct cmd_context *cmd;
+
+	if (vg) {
+		mem = vg->vgmem;
+		cmd = vg->cmd;
+	} else if (lv) {
+		mem = lv->vg->vgmem;
+		cmd = lv->vg->cmd;
+	} else if (pv) {
+		mem = pv->vg->vgmem;
+		cmd = pv->vg->cmd;
+	} else if (seg) {
+		mem = seg->lv->vg->vgmem;
+		cmd = seg->lv->vg->cmd;
+	} else if (pvseg) {
+		mem = pvseg->pv->vg->vgmem;
+		cmd = pvseg->pv->vg->cmd;
+	} else {
+		stack;
+		return 0;
+	}
+
+	if (!(rh = report_init(cmd, field_id, "", &report_type,
+				   " ", 1, 1, 1, 0, 0, 0))) {
+		stack;
+		return 0;
+	}
+
+	if (!report_object(rh, vg, lv, pv, seg, pvseg)) {
+		dm_report_free(rh);
+		stack;
+		return 0;
+	}
+
+	if (!dm_report_get_field_value(rh, field_id, value)) {
+		dm_report_free(rh);
+		stack;
+		return 0;
+	}
+
+	if (!value->is_string) {
+		dm_report_free(rh);
+		return 1;
+	}
+
+	if (!(value->u.s_val = dm_pool_strdup(mem, value->u.s_val))) {
+		log_errno(ENOMEM, "Memory allocation fail for attribute value");
+		dm_report_free(rh);
+		return 0;
+	}
+	dm_report_free(rh);
+	return 1;
+}
diff --git a/lib/report/report.h b/lib/report/report.h
index 26cc2f7..c3c1d7b 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -41,6 +41,13 @@ void report_free(void *handle);
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
 		  struct lv_segment *seg, struct pv_segment *pvseg);
+int report_value(struct volume_group *vg,
+		 struct logical_volume *lv,
+		 struct physical_volume *pv,
+		 struct lv_segment *seg,
+		 struct pv_segment *pvseg,
+		 const char *field_id,
+		 struct dm_report_field_value_type *value);
 int report_output(void *handle);
 
 #endif
-- 
1.6.0.6


