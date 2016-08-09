From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:40:06 +0000 (UTC)
Subject: master - man: fix references to names for --configreport arg in pvs, vgs and lvs man page
Message-ID: <20160809174006.C66AD607B8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b4f0503d1b55f0f28dbb0d53192aa0ed77423c37
Commit:        b4f0503d1b55f0f28dbb0d53192aa0ed77423c37
Parent:        6fcfa2855ba89f2516a22265a8ed1a70fd841aff
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 9 17:55:34 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:49:11 2016 +0200

man: fix references to names for --configreport arg in pvs, vgs and lvs man page

---
 man/lvs.8.in |    2 +-
 man/pvs.8.in |    2 +-
 man/vgs.8.in |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/lvs.8.in b/man/lvs.8.in
index 3cb2d2b..48ef866 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -71,7 +71,7 @@ the "unknown" value which denotes that the value could not be determined).
 .B \-\-configreport  \fI ReportName
 Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
 \fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
-is either 'lvs' for command's main report or 'log' for log report.
+is either 'lv' for command's main report or 'log' for log report.
 If \fB\-\-configreport\fP option is not used to identify a report, then
 command's main report is assumed. The log report is available only if
 enabled by \fBlog/report_command_log\fP \fBlvm.conf\fP(5) setting or
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 0a60b6f..54f21c3 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -60,7 +60,7 @@ the "unknown" value which denotes that the value could not be determined).
 .B \-\-configreport  \fI ReportName
 Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
 \fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
-is either 'pvs' for command's main report or 'log' for log report.
+is either 'pv' for command's main report or 'log' for log report.
 If \fB\-\-configreport\fP option is not used to identify a report, then
 command's main report is assumed. The log report is available only if
 enabled by \fBlog/report_command_log\fP \fBlvm.conf\fP(5) setting or
diff --git a/man/vgs.8.in b/man/vgs.8.in
index ab9d9ac..080086c 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -58,7 +58,7 @@ the "unknown" value which denotes that the value could not be determined).
 .B \-\-configreport  \fI ReportName
 Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
 \fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
-is either 'vgs' for command's main report or 'log' for log report.
+is either 'vg' for command's main report or 'log' for log report.
 If \fB\-\-configreport\fP option is not used to identify a report, then
 command's main report is assumed. The log report is available only if
 enabled by \fBlog/report_command_log\fP \fBlvm.conf\fP(5) setting or


