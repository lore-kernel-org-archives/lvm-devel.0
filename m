From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 26 Jun 2018 09:43:41 -0400
Subject: 2018-05-17-put-format1-and-pool-back - build: make generate
Message-ID: <201806261343.w5QDhflI008883@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=202bfdec9bf013af5f06b5448d711f4dbd1678f7
Commit:        202bfdec9bf013af5f06b5448d711f4dbd1678f7
Parent:        7cd35b62b841bd04b7057a937ee210a0a5b28332
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jun 26 15:41:02 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jun 26 15:41:02 2018 +0200

build: make generate

---
 conf/example.conf.in      |   20 ++++++++++++++++----
 man/pvcreate.8_pregen     |    7 ++++---
 man/vgcfgrestore.8_pregen |    9 +++++----
 man/vgconvert.8_pregen    |   14 +++++++++-----
 man/vgcreate.8_pregen     |    7 ++++---
 man/vgextend.8_pregen     |    7 ++++---
 man/vgsplit.8_pregen      |    7 ++++---
 7 files changed, 46 insertions(+), 25 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 4c62aad..d90c790 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -702,17 +702,29 @@ global {
 	activation = 1
 
 	# Configuration option global/fallback_to_lvm1.
-	# This setting is no longer used.
+	# Try running LVM1 tools if LVM cannot communicate with DM.
+	# This option only applies to 2.4 kernels and is provided to help
+	# switch between device-mapper kernels and LVM1 kernels. The LVM1
+	# tools need to be installed with .lvm1 suffices, e.g. vgscan.lvm1.
+	# They will stop working once the lvm2 on-disk metadata format is used.
 	# This configuration option has an automatic default value.
-	# fallback_to_lvm1 = 0
+	# fallback_to_lvm1 = @DEFAULT_FALLBACK_TO_LVM1@
 
 	# Configuration option global/format.
-	# This setting is no longer used.
+	# The default metadata format that commands should use.
+	# The -M 1|2 option overrides this setting.
+	# 
+	# Accepted values:
+	#   lvm1
+	#   lvm2
+	# 
 	# This configuration option has an automatic default value.
 	# format = "lvm2"
 
 	# Configuration option global/format_libraries.
-	# This setting is no longer used.
+	# Shared libraries that process different metadata formats.
+	# If support for LVM1 metadata was compiled as a shared library use
+	# format_libraries = "liblvm2format1.so"
 	# This configuration option does not have a default value defined.
 
 	# Configuration option global/segment_libraries.
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index c4b03da..abceb82 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -38,7 +38,7 @@ normally prevent it, e.g. if the PV is already in a VG.
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
@@ -266,11 +266,12 @@ The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is no longer used.
+\fBlvm1\fP (or just \fB1\fP) is a historical format that
+can be used for accessing old data.
 .ad b
 .HP
 .ad l
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index cffd44b..e028103 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -51,7 +51,7 @@ vgcfgrestore - Restore volume group configuration
 .ad b
 .br
 .ad l
- \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
+ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .ad b
 .br
 .ad l
@@ -141,7 +141,7 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
@@ -280,11 +280,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is no longer used.
+\fBlvm1\fP (or just \fB1\fP) is a historical format that
+can be used for accessing old data.
 .ad b
 .HP
 .ad l
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 5e7f8a9..6228087 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -8,9 +8,12 @@ vgconvert - Change volume group metadata format
     [ \fIoption_args\fP ]
 .br
 .SH DESCRIPTION
-vgconvert converts VG metadata from one format to another.  This command
-is no longer used because this version of lvm no longer supports the LVM1
+vgconvert converts VG metadata from one format to another.  The new
+metadata format must be able to fit into the space provided by the old
 format.
+
+Because the LVM1 format should no longer be used, this command is no
+longer needed in general.
 .SH USAGE
 \fBvgconvert\fP \fIVG\fP ...
 .br
@@ -20,7 +23,7 @@ format.
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
@@ -191,11 +194,12 @@ The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is no longer used.
+\fBlvm1\fP (or just \fB1\fP) is a historical format that
+can be used for accessing old data.
 .ad b
 .HP
 .ad l
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 09bf126..ddad391 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -33,7 +33,7 @@ devices are also available with vgcreate.
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
@@ -324,11 +324,12 @@ The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is no longer used.
+\fBlvm1\fP (or just \fB1\fP) is a historical format that
+can be used for accessing old data.
 .ad b
 .HP
 .ad l
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index a6a30e9..ee805a8 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -36,7 +36,7 @@ will initialize them. In this case pvcreate options can be used, e.g.
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
@@ -237,11 +237,12 @@ The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is no longer used.
+\fBlvm1\fP (or just \fB1\fP) is a historical format that
+can be used for accessing old data.
 .ad b
 .HP
 .ad l
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 6c3e6ec..210c266 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -62,7 +62,7 @@ Common options for command:
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
 .ad b
 .br
 .ad l
@@ -230,11 +230,12 @@ and --vgmetadatacopies for improving performance.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is no longer used.
+\fBlvm1\fP (or just \fB1\fP) is a historical format that
+can be used for accessing old data.
 .ad b
 .HP
 .ad l


