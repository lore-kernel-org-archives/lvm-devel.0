From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:15 +0000 (UTC)
Subject: master - reporter: Adapt pvseg reporting to label-type fields.
Message-ID: <20131117222715.58C7261327@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14ffc9d4df952346ce4338939b3ed869b8b491b4
Commit:        14ffc9d4df952346ce4338939b3ed869b8b491b4
Parent:        22942821841da6e84f3fd6c988ed6a3a37401ba6
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Aug 28 14:11:59 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:43:06 2013 +0100

reporter: Adapt pvseg reporting to label-type fields.

---
 lib/report/report.c |   11 ++++++++---
 tools/reporter.c    |    2 +-
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 9fd75bb..e4ad2c3 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -727,10 +727,15 @@ static int _pvuuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_
 	const struct label *label = (const struct label *) data;
 	char *repstr = NULL;
 
-	if (!(repstr = id_format_and_copy(mem, label->dev->pvid)))
-		return_0;
+	if (!label->dev)
+		dm_report_field_set_value(field, "", NULL);
+	else {
+		if (!(repstr = id_format_and_copy(mem, label->dev->pvid)))
+			return_0;
+
+		dm_report_field_set_value(field, repstr, NULL);
+	}
 
-	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
 }
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 28e178c..fb01686 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -107,7 +107,7 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 	dm_list_init(&_free_logical_volume.snapshot_segs);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
-			   seg ? : &_free_lv_segment, pvseg, NULL)) {
+			   seg ? : &_free_lv_segment, pvseg, pv_label(pvseg->pv))) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}


