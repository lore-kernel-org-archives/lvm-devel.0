From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  5 Dec 2014 13:19:29 +0000 (UTC)
Subject: master - libdm: report: compact output applicable only if report is buffered
Message-ID: <20141205131929.18FD860EF6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f867dc6b294c434e69499e38e66a67812361d8c9
Commit:        f867dc6b294c434e69499e38e66a67812361d8c9
Parent:        f3bd9a2797816e1d21003914c4bfa6c19eb3be62
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 5 14:18:32 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Dec 5 14:18:51 2014 +0100

libdm: report: compact output applicable only if report is buffered

---
 conf/example.conf.in |    3 ++-
 libdm/libdevmapper.h |    2 ++
 libdm/libdm-report.c |    3 +++
 3 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 5ed2b92..70d3e6b 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1105,7 +1105,8 @@ activation {
 #
 # report {
     # If compact output is enabled, fields which don't have value
-    # set for any of the rows reported are skipped on output.
+    # set for any of the rows reported are skipped on output. Compact
+    # output is applicable only if report is buffered (report/buffered=1).
     # compact_output=0
 
     # Align columns on report output.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index fef0351..f18fba9 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1757,6 +1757,8 @@ int dm_report_object(struct dm_report *rh, void *object);
 /*
  * Compact report output so that if field value is empty for all rows in
  * the report, drop the field from output completely (including headers).
+ * Compact output is applicable only if report is buffered, otherwise
+ * this function has no effect.
  */
 int dm_report_compact_fields(struct dm_report *rh);
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 7dd52d4..f81d964 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1696,6 +1696,9 @@ int dm_report_compact_fields(struct dm_report *rh)
 	struct field_properties *fp;
 	struct row *row;
 
+	if (!(rh->flags & DM_REPORT_OUTPUT_BUFFERED))
+		return 1;
+
 	if (!rh || dm_list_empty(&rh->rows)) {
 		log_error("dm_report_enable_compact_output: no report fields to compact");
 		return 0;


