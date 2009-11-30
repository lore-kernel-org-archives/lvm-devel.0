From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:05 +0100
Subject: [PATCH 05/23] Export outfc() macro and out_text_with_comment()
In-Reply-To: <1259581043-15308-5-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-6-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Support also commented lines with out_text_with_comment() API call.
It is similar to out_text() function and it takes extra argument
for comment. Macro outfc() is similar to outf().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/export.c      |    6 +++---
 lib/format_text/text_export.h |    4 ++++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 8010121..f0647e7 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -286,9 +286,9 @@ int out_hint(struct formatter *f, const char *fmt, ...)
 }
 
 /*
- * Appends a comment
+ * The normal output function with comment
  */
-static int _out_comment(struct formatter *f, const char *comment, const char *fmt, ...)
+int out_text_with_comment(struct formatter *f, const char *comment, const char *fmt, ...)
 {
 	va_list ap;
 	int r;
@@ -579,7 +579,7 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 
 	switch (lv->read_ahead) {
 	case DM_READ_AHEAD_NONE:
-		_out_comment(f, "# None", "read_ahead = -1");
+		outfc(f, "# None", "read_ahead = -1");
 		break;
 	case DM_READ_AHEAD_AUTO:
 		/* No output - use default */
diff --git a/lib/format_text/text_export.h b/lib/format_text/text_export.h
index a452439..63c8999 100644
--- a/lib/format_text/text_export.h
+++ b/lib/format_text/text_export.h
@@ -18,6 +18,7 @@
 
 #define outsz(args...) do {if (!out_size(args)) return_0;} while (0)
 #define outhnt(args...) do {if (!out_hint(args)) return_0;} while (0)
+#define outfc(args...) do {if (!out_text_with_comment(args)) return_0;} while (0)
 #define outf(args...) do {if (!out_text(args)) return_0;} while (0)
 #define outnl(f) do {if (!out_newline(f)) return_0;} while (0)
 
@@ -39,6 +40,9 @@ int out_config_node(struct formatter *f, const struct config_node *cn);
 int out_areas(struct formatter *f, const struct lv_segment *seg,
 	      const char *type);
 
+int out_text_with_comment(struct formatter *f, const char* comment, const char *fmt, ...)
+    __attribute__ ((format(printf, 3, 4)));
+
 void out_inc_indent(struct formatter *f);
 void out_dec_indent(struct formatter *f);
 int out_newline(struct formatter *f);
-- 
1.6.5.3


