From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  5 Oct 2009 16:00:28 +0200
Subject: [PATCH 01/13] Replicator: export out_ function for modules
Message-ID: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Exporting functions out_inc_indent(), out_dec_indent(), out_newline()
for creating indented metadata lines.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/export.c      |   19 +++++++++++++++++++
 lib/format_text/text_export.h |    4 ++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 482eea9..49cf785 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -235,6 +235,25 @@ static int _sectors_to_units(uint64_t sectors, char *buffer, size_t s)
 	return dm_snprintf(buffer, s, "# %g %s", d, _units[i]) > 0;
 }
 
+/* increment indention level */
+void out_inc_indent(struct formatter *f)
+{
+	_inc_indent(f);
+}
+
+/* decrement indention level */
+void out_dec_indent(struct formatter *f)
+{
+	_dec_indent(f);
+}
+
+/* insert new line */
+int out_newline(struct formatter *f)
+{
+	outnl(f);
+	return 0;
+}
+
 /*
  * Appends a comment giving a size in more easily
  * readable form (eg, 4M instead of 8096).
diff --git a/lib/format_text/text_export.h b/lib/format_text/text_export.h
index 2f2b531..12a8691 100644
--- a/lib/format_text/text_export.h
+++ b/lib/format_text/text_export.h
@@ -34,4 +34,8 @@ int out_text(struct formatter *f, const char *fmt, ...)
 int out_areas(struct formatter *f, const struct lv_segment *seg,
 	      const char *type);
 
+void out_inc_indent(struct formatter *f);
+void out_dec_indent(struct formatter *f);
+int out_newline(struct formatter *f);
+
 #endif
-- 
1.6.5.rc2


