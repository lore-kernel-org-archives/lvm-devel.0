From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:34 -0400
Subject: master - build: make generate
Message-ID: <201805121626.w4CGQYtY008340@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83e362cd32e4648fd386401bbdcd72374731dd67
Commit:        83e362cd32e4648fd386401bbdcd72374731dd67
Parent:        0b465d1543a46ba3994a0a53a08592f7a2838d35
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 17:02:34 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:18:23 2018 +0200

build: make generate

---
 conf/example.conf.in      |   27 ++++-----------------------
 man/lvconvert.8_pregen    |    8 +++++---
 man/pvcreate.8_pregen     |    7 +++----
 man/vgcfgrestore.8_pregen |    9 ++++-----
 man/vgconvert.8_pregen    |   14 +++++---------
 man/vgcreate.8_pregen     |    7 +++----
 man/vgextend.8_pregen     |    7 +++----
 man/vgsplit.8_pregen      |    7 +++----
 8 files changed, 30 insertions(+), 56 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index aab274d..92af8d3 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -702,29 +702,17 @@ global {
 	activation = 1
 
 	# Configuration option global/fallback_to_lvm1.
-	# Try running LVM1 tools if LVM cannot communicate with DM.
-	# This option only applies to 2.4 kernels and is provided to help
-	# switch between device-mapper kernels and LVM1 kernels. The LVM1
-	# tools need to be installed with .lvm1 suffices, e.g. vgscan.lvm1.
-	# They will stop working once the lvm2 on-disk metadata format is used.
+	# This setting setting no longer used.
 	# This configuration option has an automatic default value.
-	# fallback_to_lvm1 = @DEFAULT_FALLBACK_TO_LVM1@
+	# fallback_to_lvm1 = 0
 
 	# Configuration option global/format.
-	# The default metadata format that commands should use.
-	# The -M 1|2 option overrides this setting.
-	# 
-	# Accepted values:
-	#   lvm1
-	#   lvm2
-	# 
+	# This setting is no longer used.
 	# This configuration option has an automatic default value.
 	# format = "lvm2"
 
 	# Configuration option global/format_libraries.
-	# Shared libraries that process different metadata formats.
-	# If support for LVM1 metadata was compiled as a shared library use
-	# format_libraries = "liblvm2format1.so"
+	# This setting is no longer used.
 	# This configuration option does not have a default value defined.
 
 	# Configuration option global/segment_libraries.
@@ -821,13 +809,6 @@ global {
 	# encountered the internal error. Please only enable for debugging.
 	abort_on_internal_errors = 0
 
-	# Configuration option global/detect_internal_vg_cache_corruption.
-	# Internal verification of VG structures.
-	# Check if CRC matches when a parsed VG is used multiple times. This
-	# is useful to catch unexpected changes to cached VG structures.
-	# Please only enable for debugging.
-	detect_internal_vg_cache_corruption = 0
-
 	# Configuration option global/metadata_read_only.
 	# No operations that change on-disk metadata are permitted.
 	# Additionally, read-only commands that encounter metadata in need of
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index e0e38b9..91691a3 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -503,7 +503,7 @@ Merge LV images that were split from a raid1 LV.
 Convert LV to a thin LV, using the original LV as an external origin.
 .br
 .P
-\fBlvconvert\fP \fB--type\fP \fBthin\fP \fB--thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_cache_raid\fP
+\fBlvconvert\fP \fB--type\fP \fBthin\fP \fB--thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_thin_cache_raid\fP
 .br
 .RS 4
 .ad l
@@ -1530,7 +1530,7 @@ Convert LV to a thin LV, using the original LV as an external origin
 (infers --type thin).
 .br
 .P
-\fBlvconvert\fP \fB-T\fP|\fB--thin\fP \fB--thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_cache_raid\fP
+\fBlvconvert\fP \fB-T\fP|\fB--thin\fP \fB--thinpool\fP \fILV\fP \fILV\fP\fI_linear_striped_thin_cache_raid\fP
 .br
 .RS 4
 .ad l
@@ -1714,7 +1714,9 @@ origin LV (first arg) to reverse a splitsnapshot command.
 .br
 -
 
-Poll LV to continue conversion (also see --startpoll).
+Poll LV to continue conversion (also see --startpoll) 
+.br
+or waits till conversion/mirror syncing is finished
 .br
 .P
 \fBlvconvert\fP \fILV\fP\fI_mirror_raid\fP
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index abceb82..c4b03da 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -38,7 +38,7 @@ normally prevent it, e.g. if the PV is already in a VG.
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
 .ad b
 .br
 .ad l
@@ -266,12 +266,11 @@ The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is a historical format that
-can be used for accessing old data.
+\fBlvm1\fP (or just \fB1\fP) is no longer used.
 .ad b
 .HP
 .ad l
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index e028103..cffd44b 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -51,7 +51,7 @@ vgcfgrestore - Restore volume group configuration
 .ad b
 .br
 .ad l
- \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .ad b
 .br
 .ad l
@@ -141,7 +141,7 @@ Common options for command:
 .
 .RS 4
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
 .ad b
 .br
 .ad l
@@ -280,12 +280,11 @@ Display long help text.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is a historical format that
-can be used for accessing old data.
+\fBlvm1\fP (or just \fB1\fP) is no longer used.
 .ad b
 .HP
 .ad l
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 6228087..5e7f8a9 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -8,12 +8,9 @@ vgconvert - Change volume group metadata format
     [ \fIoption_args\fP ]
 .br
 .SH DESCRIPTION
-vgconvert converts VG metadata from one format to another.  The new
-metadata format must be able to fit into the space provided by the old
+vgconvert converts VG metadata from one format to another.  This command
+is no longer used because this version of lvm no longer supports the LVM1
 format.
-
-Because the LVM1 format should no longer be used, this command is no
-longer needed in general.
 .SH USAGE
 \fBvgconvert\fP \fIVG\fP ...
 .br
@@ -23,7 +20,7 @@ longer needed in general.
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
 .ad b
 .br
 .ad l
@@ -194,12 +191,11 @@ The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is a historical format that
-can be used for accessing old data.
+\fBlvm1\fP (or just \fB1\fP) is no longer used.
 .ad b
 .HP
 .ad l
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index ddad391..09bf126 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -33,7 +33,7 @@ devices are also available with vgcreate.
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
 .ad b
 .br
 .ad l
@@ -324,12 +324,11 @@ The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is a historical format that
-can be used for accessing old data.
+\fBlvm1\fP (or just \fB1\fP) is no longer used.
 .ad b
 .HP
 .ad l
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index ee805a8..a6a30e9 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -36,7 +36,7 @@ will initialize them. In this case pvcreate options can be used, e.g.
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
 .ad b
 .br
 .ad l
@@ -237,12 +237,11 @@ The size may be rounded.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is a historical format that
-can be used for accessing old data.
+\fBlvm1\fP (or just \fB1\fP) is no longer used.
 .ad b
 .HP
 .ad l
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 210c266..6c3e6ec 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -62,7 +62,7 @@ Common options for command:
 .ad b
 .br
 .ad l
-[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP ]
+[ \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP ]
 .ad b
 .br
 .ad l
@@ -230,12 +230,11 @@ and --vgmetadatacopies for improving performance.
 .ad b
 .HP
 .ad l
-\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP|\fBlvm1\fP
+\fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
-\fBlvm1\fP (or just \fB1\fP) is a historical format that
-can be used for accessing old data.
+\fBlvm1\fP (or just \fB1\fP) is no longer used.
 .ad b
 .HP
 .ad l


