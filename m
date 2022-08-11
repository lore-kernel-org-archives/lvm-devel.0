From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:12 +0000 (GMT)
Subject: main - man: update lvmreport man page about json_std format
Message-ID: <20220811110612.0DDC83858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=efd083f66883e674a6f24370d8c7cc06aa4fafe7
Commit:        efd083f66883e674a6f24370d8c7cc06aa4fafe7
Parent:        aa7cec61edae849c5fab7e1319684b43fdc439de
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 16:52:22 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

man: update lvmreport man page about json_std format

---
 man/lvmreport.7_main | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index f0f04ad1c..1ef5d25db 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -1303,9 +1303,19 @@ binary_values_as_numeric=1
 .
 LVM can output reports in different formats - use \fBreport/output_format\fP
 configuration setting (or \fB--reportformat\fP command line option) to swith
-the report output format. Currently, LVM supports \fB"basic"\fP (all the examples
-we used above used this format) and \fB"JSON"\fP output format.
+the report output format.
+
 .P
+Currently, LVM supports these outpout formats:
+.RS
+- \fB"basic"\fP (all the examples we used above used this format),
+.br
+- \fB"json"\fP,
+.br
+- \fB"json_std"\fP.
+.RE
+.P
+For example:
 .nf
 # lvs -o lv_name,lv_size --reportformat json
   {
@@ -1320,13 +1330,23 @@ we used above used this format) and \fB"JSON"\fP output format.
   }
 .fi
 .P
+The \fBjson_std\fP output format is more compliant with JSON standard and
+compared to the original \fBjson\fP format:
+.RS
+- it does not use double quotes around numeric values,
+.br
+- it uses 'null' for undefined numeric values,
+.br
+- it prints string list as proper JSON array of strings instead of a single string.
+.RE
+.P
 Note that some configuration settings and command line options have no
-effect with certain report formats. For example, with \fBJSON\fP output,
-it doesn't have any meaning to use \fBreport/aligned\fP (\fB--aligned\fP),
-\fBreport/noheadings\fP (\fB--noheadings\fP), \fBreport/columns_as_rows\fP
-(\fB--rows\fP) or \fBreport/buffered\fP (\fB--unbuffered\fP). All these
-configuration settings and command line options are ignored if using the
-\fBJSON\fP report output format.
+effect with certain report formats. For example, with \fBjson\fP or
+\fBjson_std\fP output, it doesn't have any meaning to use \fBreport/aligned\fP
+(\fB--aligned\fP), \fBreport/noheadings\fP (\fB--noheadings\fP),
+\fBreport/columns_as_rows\fP (\fB--rows\fP) or \fBreport/buffered\fP
+(\fB--unbuffered\fP). All these configuration settings and command line options
+are ignored if using the \fBjson\fP or \fBjson_std\fP report output format.
 .
 .SS Selection
 .

