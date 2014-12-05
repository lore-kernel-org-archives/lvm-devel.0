From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  5 Dec 2014 14:14:51 +0000 (UTC)
Subject: master - libdm: report: return immediately from dm_report_compact_fields without error if there are no rows
Message-ID: <20141205141451.1B3FD60354@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42d71b9af393bdbf0e9409eea176b2801a07ea25
Commit:        42d71b9af393bdbf0e9409eea176b2801a07ea25
Parent:        f867dc6b294c434e69499e38e66a67812361d8c9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 5 15:10:50 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Dec 5 15:10:50 2014 +0100

libdm: report: return immediately from dm_report_compact_fields without error if there are no rows

Let's make dm_report_compact_fields consistent with dm_report_output fn
which also returns with success immediately if there are no rows.
---
 libdm/libdm-report.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index f81d964..6d36c1e 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1696,11 +1696,12 @@ int dm_report_compact_fields(struct dm_report *rh)
 	struct field_properties *fp;
 	struct row *row;
 
-	if (!(rh->flags & DM_REPORT_OUTPUT_BUFFERED))
+	if (!(rh->flags & DM_REPORT_OUTPUT_BUFFERED) ||
+	      dm_list_empty(&rh->rows))
 		return 1;
 
-	if (!rh || dm_list_empty(&rh->rows)) {
-		log_error("dm_report_enable_compact_output: no report fields to compact");
+	if (!rh) {
+		log_error("dm_report_enable_compact_output: dm report handler is NULL.");
 		return 0;
 	}
 


