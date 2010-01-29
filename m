From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 29 Jan 2010 16:37:53 -0500
Subject: [PATCH 03/12] Add text format specific 'rlocn' flag and access functions.
In-Reply-To: <1264801082-28132-3-git-send-email-dwysocha@redhat.com>
References: <1264801082-28132-1-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-2-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1264801082-28132-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding a flag to the 'rlocn' structure in the mda header of the
text format allows us to flip a bit to disable an mda via the
text format specific mda_context structure.  This patch
defines the flag and access functions to manage the flag
inside the mda_context structure.  Other patches will manage
the disable on a format-independent basis.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks.in          |    1 +
 lib/format_text/format-text.c |   13 +++++++++++++
 lib/format_text/format-text.h |    1 +
 lib/format_text/layout.h      |    9 +++++++++
 4 files changed, 24 insertions(+), 0 deletions(-)

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
index 225b596..9b24693 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -66,6 +66,19 @@ struct text_context {
 	char *desc;		/* Description placed inside file */
 };
 
+int mdac_is_disabled(const struct mda_context *mdac)
+{
+	return mdac->rlocn.flags & RAW_LOCN_FLAG_DISABLE;
+}
+
+void mdac_set_disabled(struct mda_context *mdac, int value)
+{
+	if (value)
+		mdac->rlocn.flags |= RAW_LOCN_FLAG_DISABLE;
+	else
+		mdac->rlocn.flags &= ~RAW_LOCN_FLAG_DISABLE;
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
index 444a500..2982401 100644
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
@@ -78,6 +85,8 @@ struct mda_context {
 	uint64_t free_sectors;
 	struct raw_locn rlocn;	/* Store inbetween write and commit */
 };
+int mdac_is_disabled(const struct mda_context *mdac);
+void mdac_set_disabled(struct mda_context *mdac, int value);
 
 /* FIXME Convert this at runtime */
 #define FMTT_MAGIC "\040\114\126\115\062\040\170\133\065\101\045\162\060\116\052\076"
-- 
1.6.0.6


