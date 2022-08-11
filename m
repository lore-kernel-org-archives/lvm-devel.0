From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:13 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20220811110613.31F733858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b318c9c20f40be1583e7d0751a733f77be173012
Commit:        b318c9c20f40be1583e7d0751a733f77be173012
Parent:        efd083f66883e674a6f24370d8c7cc06aa4fafe7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 5 10:31:08 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

make: generate

---
 conf/example.conf.in         |  6 ++++++
 man/lvchange.8_pregen        | 10 ++++++----
 man/lvcreate.8_pregen        | 10 ++++++----
 man/lvextend.8_pregen        | 10 ++++++----
 man/lvm-fullreport.8_pregen  |  8 +++++---
 man/lvreduce.8_pregen        |  8 +++++---
 man/lvremove.8_pregen        |  8 +++++---
 man/lvrename.8_pregen        |  8 +++++---
 man/lvresize.8_pregen        | 10 ++++++----
 man/lvs.8_pregen             |  8 +++++---
 man/lvscan.8_pregen          |  8 +++++---
 man/pvchange.8_pregen        |  8 +++++---
 man/pvcreate.8_pregen        |  8 +++++---
 man/pvdisplay.8_pregen       |  8 +++++---
 man/pvmove.8_pregen          |  8 +++++---
 man/pvremove.8_pregen        |  8 +++++---
 man/pvresize.8_pregen        |  8 +++++---
 man/pvs.8_pregen             |  8 +++++---
 man/pvscan.8_pregen          | 14 ++++++++------
 man/vgcfgbackup.8_pregen     |  8 +++++---
 man/vgchange.8_pregen        | 18 ++++++++++--------
 man/vgck.8_pregen            |  8 +++++---
 man/vgconvert.8_pregen       |  8 +++++---
 man/vgcreate.8_pregen        |  8 +++++---
 man/vgexport.8_pregen        |  8 +++++---
 man/vgextend.8_pregen        |  8 +++++---
 man/vgimport.8_pregen        |  8 +++++---
 man/vgimportdevices.8_pregen |  8 +++++---
 man/vgmknodes.8_pregen       |  8 +++++---
 man/vgreduce.8_pregen        | 10 ++++++----
 man/vgremove.8_pregen        |  8 +++++---
 man/vgrename.8_pregen        |  8 +++++---
 man/vgs.8_pregen             |  8 +++++---
 man/vgscan.8_pregen          |  8 +++++---
 34 files changed, 184 insertions(+), 112 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 5fadeac12..10810d8b8 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1951,6 +1951,12 @@ activation {
 	#     name for identification.
 	#   json
 	#     JSON format.
+	#   json_std
+	#     JSON format that is more compliant with JSON standard.
+	#     Compared to original "json" format:
+	#       - it does not use double quotes around numeric values,
+	#       - it uses 'null' for undefined numeric values,
+	#       - it prints string list as proper JSON array of strings instead of a single string.
 	# This configuration option has an automatic default value.
 	# output_format = "basic"
 
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index e46a3b9b2..90aec5483 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -111,7 +111,7 @@ lvchange \(em Change the attributes of logical volume(s)
 .br
     \fB--refresh\fP
 .br
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
     \fB--resync\fP
 .br
@@ -397,7 +397,7 @@ Common options for command:
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .ad b
 .RE
 .P
@@ -847,14 +847,16 @@ if something has gone wrong, or if some form of manual LV
 sharing is being used.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB--resync\fP
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 3940aa77e..cde896b7a 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -129,7 +129,7 @@ lvcreate \(em Create a logical volume
 .br
  \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
 .br
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
  \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .br
@@ -781,7 +781,7 @@ Common options for command:
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--setautoactivation\fP \fBy\fP|\fBn\fP ]
 .ad b
@@ -1299,14 +1299,16 @@ Size of each raid or mirror synchronization region.
 configure a default.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 445afc25e..3c2bfa6bf 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -63,7 +63,7 @@ lvextend \(em Add space to a logical volume
 .br
  \fB-q\fP|\fB--quiet\fP
 .br
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
  \fB-r\fP|\fB--resizefs\fP
 .br
@@ -219,7 +219,7 @@ Common options for command:
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--type\fP \c
 .nh
@@ -471,14 +471,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-r\fP|\fB--resizefs\fP
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 4bcfba4f8..7e9348e1d 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -55,7 +55,7 @@ if information changes between commands.
 .br
 [    \fB--readonly\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--rows\fP ]
 .br
@@ -308,14 +308,16 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB--rows\fP
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index e8953bc8f..4f6615449 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -50,7 +50,7 @@ the options section.
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -245,14 +245,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-r\fP|\fB--resizefs\fP
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index f47181213..7ae83f1bb 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -56,7 +56,7 @@ former LV completely.
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -229,14 +229,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-S\fP|\fB--select\fP \fIString\fP
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 278e8e989..2c0c4e1b9 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -42,7 +42,7 @@ Common options for command:
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .ad b
 .RE
 .P
@@ -200,14 +200,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 625fed0a1..1671741ce 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -61,7 +61,7 @@ lvresize \(em Resize a logical volume
 .br
  \fB-q\fP|\fB--quiet\fP
 .br
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
  \fB-r\fP|\fB--resizefs\fP
 .br
@@ -177,7 +177,7 @@ Common options for command:
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--type\fP \c
 .nh
@@ -424,14 +424,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-r\fP|\fB--resizefs\fP
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index d055851f5..3f35dc652 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -55,7 +55,7 @@ lvs produces formatted output about LVs.
 .br
 [    \fB--readonly\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--rows\fP ]
 .br
@@ -318,14 +318,16 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB--rows\fP
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 012479618..e2938dee4 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -33,7 +33,7 @@ comprehensive information about LVs.
 .br
 [    \fB--readonly\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -207,14 +207,16 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 57d1570c4..0b35a2013 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -79,7 +79,7 @@ Common options for command:
 .br
 [ \fB-u\fP|\fB--uuid\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .ad b
 .RE
 .P
@@ -265,14 +265,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-S\fP|\fB--select\fP \fIString\fP
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index 67b5c27d0..3445898d0 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -124,7 +124,7 @@ pe_start value.
 .br
 [    \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT] ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--restorefile\fP \fIString\fP ]
 .br
@@ -353,14 +353,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB--restorefile\fP \fIString\fP
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index e7767d0c4..92dda936f 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -61,7 +61,7 @@ and more, using a more compact and configurable output format.
 .br
 [    \fB--readonly\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--separator\fP \fIString\fP ]
 .br
@@ -322,14 +322,16 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-S\fP|\fB--select\fP \fIString\fP
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index 28b0ea4e8..53f8a2ac6 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -54,7 +54,7 @@ Move PV extents.
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -296,14 +296,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index a086724b8..0d4802187 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -29,7 +29,7 @@ an existing VG. Normally, \fBvgreduce\fP(8) should be used instead.
 .ad l
 [ \fB-f\fP|\fB--force\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -181,14 +181,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 708b7d72a..fda57a246 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -24,7 +24,7 @@ LVs allocated on it.
 .ad l
 [    \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT] ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -170,14 +170,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 485e651a7..d08e92818 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -53,7 +53,7 @@ pvs produces formatted output about PVs.
 .br
 [    \fB--readonly\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--rows\fP ]
 .br
@@ -308,14 +308,16 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB--rows\fP
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index cb837b8ca..20aec7267 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -66,7 +66,7 @@ pvscan \(em List all physical volumes
 .br
  \fB-q\fP|\fB--quiet\fP
 .br
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
  \fB-s\fP|\fB--short\fP
 .br
@@ -157,7 +157,7 @@ Display PV information.
 .br
 [    \fB--ignorelockingfailure\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -176,7 +176,7 @@ Record that a PV is online or offline.
 .br
 [    \fB--ignorelockingfailure\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--minor\fP \fINumber\fP ]
 .br
@@ -202,7 +202,7 @@ Record that a PV is online and autoactivate the VG if complete.
 .br
 [    \fB--ignorelockingfailure\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--minor\fP \fINumber\fP ]
 .br
@@ -499,14 +499,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-s\fP|\fB--short\fP
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index e732a7d43..62707ed1f 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -46,7 +46,7 @@ It may also be useful to regularly back up the files in
 .br
 [    \fB--readonly\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -224,14 +224,16 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index d70f1e5ac..9df1ef733 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -97,7 +97,7 @@ vgchange \(em Change volume group attributes
 .br
     \fB--refresh\fP
 .br
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
  \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP
 .br
@@ -184,7 +184,7 @@ required, after which the others are optional.
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -218,7 +218,7 @@ Start or stop monitoring LVs from dmeventd.
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -248,7 +248,7 @@ Start or stop processing LV conversions.
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -294,7 +294,7 @@ Activate or deactivate LVs.
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -328,7 +328,7 @@ Reactivate LVs using the latest metadata.
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -780,14 +780,16 @@ if something has gone wrong, or if some form of manual LV
 sharing is being used.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 23bd7ea6d..d0fe0403e 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -26,7 +26,7 @@ Read and display information about a VG.
 .br
 .RS 4
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -186,14 +186,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index cdeee39fa..41baaf9ad 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -35,7 +35,7 @@ convert VGs from the LVM1 format to LVM2.
 .br
 [    \fB--metadatasize\fP \fISize\fP[m|UNIT] ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -234,14 +234,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 2c0c548b5..07fc9e485 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -63,7 +63,7 @@ device.
 .br
 [    \fB--\fP[\fBvg\fP]\fBmetadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--dataalignment\fP \fISize\fP[k|UNIT] ]
 .br
@@ -351,14 +351,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB--setautoactivation\fP \fBy\fP|\fBn\fP
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index 25f767bc8..4fa6eadbf 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -63,7 +63,7 @@ Common options for command:
 .
 .RS 4
 .ad l
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .ad b
 .RE
 .P
@@ -211,14 +211,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-S\fP|\fB--select\fP \fIString\fP
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index af5679118..a1ed2f3e3 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -51,7 +51,7 @@ will initialize them. In this case pvcreate options can be used, e.g.
 .br
 [    \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT] ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--restoremissing\fP ]
 .br
@@ -265,14 +265,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB--restoremissing\fP
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index fee109849..f23f8f4f1 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -51,7 +51,7 @@ Common options for command:
 .ad l
 [ \fB-f\fP|\fB--force\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .ad b
 .RE
 .P
@@ -206,14 +206,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-S\fP|\fB--select\fP \fIString\fP
diff --git a/man/vgimportdevices.8_pregen b/man/vgimportdevices.8_pregen
index c030c01a5..1cce85766 100644
--- a/man/vgimportdevices.8_pregen
+++ b/man/vgimportdevices.8_pregen
@@ -56,7 +56,7 @@ Common options for command:
 .ad l
 [    \fB--foreign\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .ad b
 .RE
 .P
@@ -210,14 +210,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-S\fP|\fB--select\fP \fIString\fP
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 511d579bd..60e693571 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -31,7 +31,7 @@ interoperating correctly.
 .br
 [    \fB--refresh\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -194,14 +194,16 @@ if something has gone wrong, or if some form of manual LV
 sharing is being used.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index 278aa0fac..ca6ab6786 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -50,7 +50,7 @@ vgreduce \(em Remove physical volume(s) from a volume group
 .br
     \fB--removemissing\fP
 .br
-    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
  \fB-t\fP|\fB--test\fP
 .br
@@ -116,7 +116,7 @@ Common options for command:
 .br
 [ \fB-f\fP|\fB--force\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .ad b
 .RE
 .P
@@ -296,14 +296,16 @@ If LVs spanned several disks, including ones that are lost, salvaging
 some data first may be possible by activating LVs in partial mode.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index 9e6051ade..df6588115 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -35,7 +35,7 @@ without confirmation.
 .br
 [    \fB--noudevsync\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -195,14 +195,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-S\fP|\fB--select\fP \fIString\fP
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 932a51103..d55b6a0f9 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -55,7 +55,7 @@ Common options for command:
 .br
 [ \fB-f\fP|\fB--force\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .ad b
 .RE
 .P
@@ -211,14 +211,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index 0c89c5b5e..8b1f69c4f 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -51,7 +51,7 @@ vgs produces formatted output about VGs.
 .br
 [    \fB--readonly\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [    \fB--rows\fP ]
 .br
@@ -305,14 +305,16 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB--rows\fP
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 600c2c978..7b4ffb615 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -27,7 +27,7 @@ vgscan scans all supported LVM block devices in the system for VGs.
 .br
 [    \fB--notifydbus\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP ]
 .br
 [ COMMON_OPTIONS ]
 .ad b
@@ -192,14 +192,16 @@ Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+\fB--reportformat\fP \fBbasic\fP|\fBjson\fP|\fBjson_std\fP
 .br
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in \fBlvm.conf\fP(5).
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
+output in JSON format. \fBjson_std\fP produces report output in
+JSON format which is more compliant with JSON standard.
+See \fBlvmreport\fP(7) for more information.
 .
 .HP
 \fB-t\fP|\fB--test\fP

