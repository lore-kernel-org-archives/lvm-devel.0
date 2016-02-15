From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:15 +0000 (UTC)
Subject: master - metadata: introduce PV_EXT_USED flag and bump PV_HEADER_EXTENSION_VSN
Message-ID: <20160215120815.0214260A2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54b41db9a6c2ec78c5c768972dda59283563eb9d
Commit:        54b41db9a6c2ec78c5c768972dda59283563eb9d
Parent:        a522af93b7365d183fd7f82ac65cc7f3bed2423a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 12 13:20:34 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

metadata: introduce PV_EXT_USED flag and bump PV_HEADER_EXTENSION_VSN

---
 lib/format_text/layout.h         |    7 ++++++-
 lib/metadata/metadata-exported.h |    3 +++
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index b8a2774..75a935b 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -23,7 +23,12 @@
 
 /* disk_locn and data_area_list are defined in format-text.h */
 
-#define PV_HEADER_EXTENSION_VSN 1
+/*
+ * PV header extension versions:
+ *   - version 1: bootloader area support
+ *   - version 2: PV_EXT_USED flag support
+ */
+#define PV_HEADER_EXTENSION_VSN 2
 
 struct pv_header_extension {
 	uint32_t version;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5cf7c88..fc09e2e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -40,6 +40,9 @@
 /* Layer suffix */
 #define MIRROR_SYNC_LAYER "_mimagetmp"
 
+/* PV extension flags */
+#define PV_EXT_USED		UINT32_C(0x00000001)
+
 /* Various flags */
 /* Note that the bits no longer necessarily correspond to LVM1 disk format */
 


