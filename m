From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:05 -0500
Subject: [PATCH 02/21] Add text format specific 'rlocn' disable flag and access functions.
In-Reply-To: <1265754744-17319-2-git-send-email-dwysocha@redhat.com>
References: <1265754744-17319-1-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1265754744-17319-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding a flag to the 'rlocn' structure in the mda header of the
text format allows us to flip a bit to disable an mda via the
text format specific mda_header and mda_context structures.  This
patch defines the flag and access functions to manage the flag.
Other patches will manage the disable on a format-independent basis.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks.in          |    1 +
 lib/format_text/format-text.c |   13 +++++++++++++
 lib/format_text/format-text.h |    1 +
 lib/format_text/layout.h      |   10 ++++++++++
 4 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 5a7e556..415bf82 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -26,6 +26,7 @@
 @top_srcdir@/lib/format_text/format-text.h
 @top_srcdir@/lib/format_text/text_export.h
 @top_srcdir@/lib/format_text/text_import.h
+ at top_srcdir@/lib/format_text/layout.h
 @top_srcdir@/lib/label/label.h
 @top_srcdir@/lib/locking/locking.h
 @top_srcdir@/lib/log/log.h
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 0c9b5e2..677c910 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -66,6 +66,19 @@ struct text_context {
 	char *desc;		/* Description placed inside file */
 };
 
+int rlocn_is_disabled(const struct raw_locn *rlocn)
+{
+	return (rlocn->flags & RAW_LOCN_FLAG_DISABLE ? 1 : 0);
+}
+
+void rlocn_set_disabled(struct raw_locn *rlocn, int value)
+{
+	if (value)
+		rlocn->flags |= RAW_LOCN_FLAG_DISABLE;
+	else
+		rlocn->flags &= ~RAW_LOCN_FLAG_DISABLE;
+}
+
 /*
  * NOTE: Currently there can be only one vg per text file.
  */
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 9750ffa..17997cc 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -17,6 +17,7 @@
 #define _LVM_FORMAT_TEXT_H
 
 #include "lvm-types.h"
+#include "layout.h"
 #include "metadata.h"
 
 #define FMT_TEXT_NAME "lvm2"
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 444a500..738902d 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -46,6 +46,13 @@ struct pv_header {
 	struct disk_locn disk_areas_xl[0];	/* Two lists */
 } __attribute__ ((packed));
 
+/*
+ * Disable this raw location.  This allows us to enable/disable
+ * metadata easily, and thus balance metadata across VGs with
+ * many PVs.
+ */
+#define RAW_LOCN_FLAG_DISABLE 0x00000001
+
 /* On disk */
 struct raw_locn {
 	uint64_t offset;	/* Offset in bytes to start sector */
@@ -54,6 +61,9 @@ struct raw_locn {
 	uint32_t flags;
 } __attribute__ ((packed));
 
+int rlocn_is_disabled(const struct raw_locn *rlocn);
+void rlocn_set_disabled(struct raw_locn *rlocn, int value);
+
 /* On disk */
 /* Structure size limited to one sector */
 struct mda_header {
-- 
1.6.0.6


