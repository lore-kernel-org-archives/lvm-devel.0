From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:21 -0500
Subject: [PATCH 18/21] Add vg_mda_balance_{min|max} display fields to 'vgs' command.
In-Reply-To: <1265754744-17319-18-git-send-email-dwysocha@redhat.com>
References: <1265754744-17319-1-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-2-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-3-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-4-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-5-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-6-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-7-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-8-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-9-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-10-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-11-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-12-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-13-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-14-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-15-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-16-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-17-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-18-git-send-email-dwysocha@redhat.com>
Message-ID: <1265754744-17319-19-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/columns.h |    2 ++
 lib/report/report.c  |   24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 9dd67d9..f0c3d28 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -115,6 +115,8 @@ FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata
 FIELD(VGS, vg, NUM, "#VMdaDis", cmd, 8, vgmdas_disabled, "vg_mda_count_disabled", "Number of metadata areas disabled in this VG.")
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, "vg_mda_size", "Size of smallest metadata area for this VG in current units.")
+FIELD(VGS, vg, NUM, "#VMdaMin", cmd, 8, vgmda_balance_min, "vg_mda_balance_min", "Minimum number of PVs on which to read/write metadata.")
+FIELD(VGS, vg, NUM, "#VMdaMax", cmd, 8, vgmda_balance_max, "vg_mda_balance_max", "Maximum number of PVs on which to read/write metadata.")
 
 FIELD(SEGS, seg, STR, "Type", list, 4, segtype, "segtype", "Type of LV segment.")
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, "stripes", "Number of stripes or mirror legs.")
diff --git a/lib/report/report.c b/lib/report/report.c
index e6a5785..40a76b8 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -898,6 +898,30 @@ static int _vgmdas_disabled_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _vgmda_balance_min_disp(struct dm_report *rh, struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint32_t count;
+
+	count = vg_mda_balance_min(vg);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
+static int _vgmda_balance_max_disp(struct dm_report *rh, struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	uint32_t count;
+
+	count = vg_mda_balance_max(vg);
+
+	return _uint32_disp(rh, mem, field, &count, private);
+}
+
 static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
-- 
1.6.0.6


