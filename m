From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 20 Aug 2013 23:36:13 +0000 (UTC)
Subject: dev-dct-process-part3 - reporter: Deal correctly with dummy PVs/labels.
Message-ID: <20130820233613.B2D7560DE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=785d5122132450ca206eb187df69125b978af43c
Commit:        785d5122132450ca206eb187df69125b978af43c
Parent:        53516ea789b8b8f71ac84468f38ce9a0c40f9649
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Aug 21 01:31:46 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 21 01:31:46 2013 +0200

reporter: Deal correctly with dummy PVs/labels.

---
 lib/report/report.c |    2 +-
 tools/reporter.c    |   14 +++++++++-----
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 07d4731..107442d 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -146,7 +146,7 @@ static int _pvfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct label *l =
 	    (const struct label *) data;
 
-	if (!l->labeller->fmt) {
+	if (!l->labeller || !l->labeller->fmt) {
 		dm_report_field_set_value(field, "", NULL);
 		return 1;
 	}
diff --git a/tools/reporter.c b/tools/reporter.c
index 5ed69d3..e1cac7f 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -124,11 +124,15 @@ static int _pvsegs_single(struct cmd_context *cmd, struct volume_group *vg,
 static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		       struct physical_volume *pv, void *handle)
 {
-	struct label *label;
-
-	label = pv_label(pv);
-	if (!label)
-		return_ECMD_FAILED;
+	struct label *label = pv_label(pv);
+	struct label _dummy = { 0 };
+
+	/* FIXME workaround for pv_label going through cache; remove once struct
+	 * physical_volume gains a proper "label" pointer */
+	if (!label) {
+		_dummy.dev = pv->dev;
+		label = &_dummy;
+	}
 
 	if (!report_object(handle, vg, NULL, pv, NULL, NULL, label))
 		return_ECMD_FAILED;


