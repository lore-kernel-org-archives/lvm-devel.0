From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:33 -0400
Subject: [PATCH 02/38] Add text format specific 'rlocn' ignore flag and access functions.
In-Reply-To: <1277520789-6808-2-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-3-git-send-email-dwysocha@redhat.com>
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
 lib/format_text/format-text.c |   13 +++++++++++++
 lib/format_text/layout.h      |   10 ++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index b6f70c0..3a032ea 100644
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


