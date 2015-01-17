From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 17 Jan 2015 10:53:26 +0000 (UTC)
Subject: master - libdm-report: Fix order of NULL dm_report check.
Message-ID: <20150117105326.0CB3260E5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=651549594ea24dd516538ca8ac1603b3b7c944f4
Commit:        651549594ea24dd516538ca8ac1603b3b7c944f4
Parent:        302b6c99a7c78e4f57b6afe4ef1007a1ba74e40b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jan 17 10:50:54 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jan 17 10:50:54 2015 +0000

libdm-report: Fix order of NULL dm_report check.

---
 libdm/libdm-report.c |    8 ++++----
 tools/reporter.c     |    1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 5ff6cda..2612f74 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1705,15 +1705,15 @@ int dm_report_compact_fields(struct dm_report *rh)
 	struct field_properties *fp;
 	struct row *row;
 
-	if (!(rh->flags & DM_REPORT_OUTPUT_BUFFERED) ||
-	      dm_list_empty(&rh->rows))
-		return 1;
-
 	if (!rh) {
 		log_error("dm_report_enable_compact_output: dm report handler is NULL.");
 		return 0;
 	}
 
+	if (!(rh->flags & DM_REPORT_OUTPUT_BUFFERED) ||
+	      dm_list_empty(&rh->rows))
+		return 1;
+
 	/*
 	 * At first, mark all fields with FLD_HIDDEN flag.
 	 * Also, mark field with FLD_COMPACTED flag, but only
diff --git a/tools/reporter.c b/tools/reporter.c
index 133ef39..f803dd8 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -418,7 +418,6 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	args_are_pvs = (report_type == PVS ||
 			report_type == LABEL ||
-
 			report_type == PVSEGS) ? 1 : 0;
 
 	/*


