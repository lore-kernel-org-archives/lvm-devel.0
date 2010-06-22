From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:05:35 -0400
Subject: [PATCH 02/35] Add text format specific 'rlocn' ignore flag and access functions.
In-Reply-To: <1277175968-9661-2-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding a flag to the 'rlocn' structure in the mda header of the
text format allows us to flip a bit to ignore an area on disk that
stores the metadata via the text format specific mda_header.
This patch defines the flag and access functions to manage the flag.
Other patches will manage the ignore on a format-independent basis,
by using a flag in the metadata_area structure.

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
index 6e02f12..9599626 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -66,6 +66,19 @@ struct text_context {
 	char *desc;		/* Description placed inside file */
 };
 
+int rlocn_is_ignored(const struct raw_locn *rlocn)
+{
+	return (rlocn->flags & RAW_LOCN_IGNORED ? 1 : 0);
+}
+
+void rlocn_set_ignored(struct raw_locn *rlocn, int value)
+{
+	if (value)
+		rlocn->flags |= RAW_LOCN_IGNORED;
+	else
+		rlocn->flags &= ~RAW_LOCN_IGNORED;
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
index 444a500..b7b2f2b 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -46,6 +46,13 @@ struct pv_header {
 	struct disk_locn disk_areas_xl[0];	/* Two lists */
 } __attribute__ ((packed));
 
+/*
+ * Ignore this raw location.  This allows us to
+ * ignored metadata areas easily, and thus balance
+ * metadata across VGs with many PVs.
+ */
+#define RAW_LOCN_IGNORED 0x00000001
+
 /* On disk */
 struct raw_locn {
 	uint64_t offset;	/* Offset in bytes to start sector */
@@ -54,6 +61,9 @@ struct raw_locn {
 	uint32_t flags;
 } __attribute__ ((packed));
 
+int rlocn_is_ignored(const struct raw_locn *rlocn);
+void rlocn_set_ignored(struct raw_locn *rlocn, int value);
+
 /* On disk */
 /* Structure size limited to one sector */
 struct mda_header {
-- 
1.6.0.6


