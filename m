From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:13 +0000 (UTC)
Subject: master - reporter: Deal correctly with dummy PVs/labels.
Message-ID: <20131117222713.45BC961327@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22942821841da6e84f3fd6c988ed6a3a37401ba6
Commit:        22942821841da6e84f3fd6c988ed6a3a37401ba6
Parent:        d5095222fa4f8cea89b721dcb12adad89176413e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Aug 28 14:07:26 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:43:06 2013 +0100

reporter: Deal correctly with dummy PVs/labels.

---
 lib/report/report.c |    2 +-
 tools/reporter.c    |   12 +++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index dee4ea2..9fd75bb 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -184,7 +184,7 @@ static int _pvfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct label *l =
 	    (const struct label *) data;
 
-	if (!l->labeller->fmt) {
+	if (!l->labeller || !l->labeller->fmt) {
 		dm_report_field_set_value(field, "", NULL);
 		return 1;
 	}
diff --git a/tools/reporter.c b/tools/reporter.c
index a15f8ef..28e178c 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -141,6 +141,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	struct volume_group *old_vg = vg;
 	char uuid[64] __attribute__((aligned(8)));
 	struct label *label;
+	struct label _dummy_label = { 0 };
 
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
@@ -178,9 +179,14 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		pv = pvl->pv;
 	}
 
-	if ((!(label = pv_label(pv))) ||
-	    (!report_object(handle, vg, NULL, pv, NULL, NULL, label)))
-	{
+	/* FIXME workaround for pv_label going through cache; remove once struct
+	 * physical_volume gains a proper "label" pointer */
+	if (!(label = pv_label(pv))) {
+		_dummy_label.dev = pv->dev;
+		label = &_dummy_label;
+	}
+
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL, label)) {
 		stack;
 		ret = ECMD_FAILED;
 	}


