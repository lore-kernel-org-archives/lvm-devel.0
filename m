From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Jun 2014 09:56:41 +0000 (UTC)
Subject: master - report: avoid passing NULL label
Message-ID: <20140612095641.E8A4861384@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=922f884abeae010589fa775b022d284dfec9e075
Commit:        922f884abeae010589fa775b022d284dfec9e075
Parent:        c230ae95abf4e0dd08183c37d204b0145ce0a5e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 12 11:33:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 12 11:55:58 2014 +0200

report: avoid passing NULL label

Internal reporting function cannot handle NULL reporting value,
so ensure there is at least dummy label.

So move dummy_lable from tools/reporter.c and use it for all
report_object() calls in lib/report/report.c.
(Fixes RHBZ 1108394)

Simlify lvm_report_object initialization.
---
 WHATS_NEW           |    1 +
 lib/report/report.c |   32 ++++++++++++++++++++++++--------
 tools/reporter.c    |   20 +-------------------
 3 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4310dd1..b77d404 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Fix crash when reporting of empty labels on pvs.
   Use retry_deactivation also when cleaning orphan devices.
   Prompt when setting the VG cluster attr if the cluster is not setup.
   Allow --yes to skip prompt in vgextend (worked only with -f).
diff --git a/lib/report/report.c b/lib/report/report.c
index 681e80c..6b32bee 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1274,19 +1274,35 @@ int report_object(void *handle, struct volume_group *vg,
 		  struct lv_segment *seg, struct pv_segment *pvseg,
 		  struct label *label)
 {
-	struct lvm_report_object obj;
+	struct device dummy_device = { .dev = 0 };
+	struct label dummy_label = { .dev = &dummy_device };
+	struct lvm_report_object obj = {
+		.vg = vg,
+		.lv = lv,
+		.pv = pv,
+		.seg = seg,
+		.pvseg = pvseg,
+		.label = label ? : (pv ? pv_label(pv) : NULL)
+	};
+
+	/* FIXME workaround for pv_label going through cache; remove once struct
+	 * physical_volume gains a proper "label" pointer */
+	if (!obj.label) {
+		if (pv) {
+			if (pv->fmt)
+				dummy_label.labeller = pv->fmt->labeller;
+			if (pv->dev)
+				dummy_label.dev = pv->dev;
+			else
+				memcpy(dummy_device.pvid, &pv->id, ID_LEN);
+		}
+		obj.label = &dummy_label;
+	}
 
 	/* The two format fields might as well match. */
 	if (!vg && pv)
 		_dummy_fid.fmt = pv->fmt;
 
-	obj.vg = vg;
-	obj.lv = lv;
-	obj.pv = pv;
-	obj.seg = seg;
-	obj.pvseg = pvseg;
-	obj.label = label ? label : (pv ? pv_label(pv) : NULL);
-
 	return dm_report_object(handle, &obj);
 }
 
diff --git a/tools/reporter.c b/tools/reporter.c
index b4a0c0b..b20b8ed 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -140,9 +140,6 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	const char *vg_name = NULL;
 	struct volume_group *old_vg = vg;
 	char uuid[64] __attribute__((aligned(8)));
-	struct label *label;
-	struct label dummy_label = { .dev = 0 };
-	struct device dummy_device = { .dev = 0 };
 
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
@@ -180,22 +177,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		pv = pvl->pv;
 	}
 
-	/* FIXME workaround for pv_label going through cache; remove once struct
-	 * physical_volume gains a proper "label" pointer */
-	if (!(label = pv_label(pv))) {
-		if (pv->fmt)
-			dummy_label.labeller = pv->fmt->labeller;
-
-		if (pv->dev)
-			dummy_label.dev = pv->dev;
-		else {
-			dummy_label.dev = &dummy_device;
-			memcpy(dummy_device.pvid, &pv->id, ID_LEN);
-		}
-		label = &dummy_label;
-	}
-
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL, label)) {
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL, NULL)) {
 		stack;
 		ret = ECMD_FAILED;
 	}


