From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat,  8 Aug 2015 16:50:16 +0000 (UTC)
Subject: master - libdm: do not attempt to output column headings with --rows
Message-ID: <20150808165016.E5B3E610FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3638c05ec95e0fa445f06b05567189b712a0b8a9
Commit:        3638c05ec95e0fa445f06b05567189b712a0b8a9
Parent:        54815fff0694ab562d041a4de1ee54ac0cd10f48
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Aug 8 17:31:36 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Aug 8 17:48:30 2015 +0100

libdm: do not attempt to output column headings with --rows

Columns-as-rows output does not use _report_headings(); don't
try to call it when rh->flags & DM_REPORT_OUTPUT_COLUMNS_AS_ROWS.
---
 libdm/libdm-report.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index de87ca4..17a7e13 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -3994,6 +3994,9 @@ static int _report_headings(struct dm_report *rh)
 
 int dm_report_column_headings(struct dm_report *rh)
 {
+	/* Columns-as-rows does not use _report_headings. */
+	if (rh->flags & DM_REPORT_OUTPUT_COLUMNS_AS_ROWS)
+		return 1;
 	return _report_headings(rh);
 }
 


