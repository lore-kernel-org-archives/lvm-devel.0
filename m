From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  7 Mar 2016 09:44:16 +0000 (UTC)
Subject: master - coverity: fix possible resource leak in _print_historical_lv function
Message-ID: <20160307094416.EC18660E95@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d03b1779b4e2edaec221e2c29d3384d4c86052cd
Commit:        d03b1779b4e2edaec221e2c29d3384d4c86052cd
Parent:        7b15ca5c9ac3645b8d714014f89dbcd6731b2b04
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 7 10:32:41 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 7 10:43:50 2016 +0100

coverity: fix possible resource leak in _print_historical_lv function

The code in _print_historical_lv function works with temporary
"descendants_buffer" that is allocated and freed within this
function.

When printing text out, we used "outf" macro which called
"out_text" fn and it checked return value and if failed,
the macro called "return_0" automatically. But since we
use the temporary buffer, if any of the out_text calls
fails, we need to deallocate this buffer properly - that's
the "goto_out", otherwise we'll be leaking memory.

So add new "outfgo" helper macro which does the same as "outf",
but it calls "goto_out" instead of "return_0" so we can jump
to a cleanup hook at the end.
---
 lib/format_text/export.c      |   12 ++++++------
 lib/format_text/text_export.h |    1 +
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index c4c7b38..90fb044 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -854,10 +854,10 @@ static int _print_historical_lv(struct formatter *f, struct historical_logical_v
 		goto_out;
 
 	outnl(f);
-	outf(f, "%s {", hlv->name);
+	outfgo(f, "%s {", hlv->name);
 	_inc_indent(f);
 
-	outf(f, "id = \"%s\"", buffer);
+	outfgo(f, "id = \"%s\"", buffer);
 
 	if (!_print_timestamp(f, "creation_time", hlv->timestamp, buffer, sizeof(buffer)))
 		goto_out;
@@ -867,16 +867,16 @@ static int _print_historical_lv(struct formatter *f, struct historical_logical_v
 
 	if (hlv->indirect_origin) {
 		if (hlv->indirect_origin->is_historical)
-			outf(f, "origin = \"%s%s\"", HISTORICAL_LV_PREFIX, hlv->indirect_origin->historical->name);
+			outfgo(f, "origin = \"%s%s\"", HISTORICAL_LV_PREFIX, hlv->indirect_origin->historical->name);
 		else
-			outf(f, "origin = \"%s\"", hlv->indirect_origin->live->name);
+			outfgo(f, "origin = \"%s\"", hlv->indirect_origin->live->name);
 	}
 
 	if (descendants_buffer)
-		outf(f, "descendants = %s", descendants_buffer);
+		outfgo(f, "descendants = %s", descendants_buffer);
 
 	_dec_indent(f);
-	outf(f, "}");
+	outfgo(f, "}");
 
 	r = 1;
 out:
diff --git a/lib/format_text/text_export.h b/lib/format_text/text_export.h
index 33c136b..377ee93 100644
--- a/lib/format_text/text_export.h
+++ b/lib/format_text/text_export.h
@@ -20,6 +20,7 @@
 #define outhint(args...) do {if (!out_hint(args)) return_0;} while (0)
 #define outfc(args...) do {if (!out_text_with_comment(args)) return_0;} while (0)
 #define outf(args...) do {if (!out_text(args)) return_0;} while (0)
+#define outfgo(args...) do {if (!out_text(args)) goto_out;} while (0)
 #define outnl(f) do {if (!out_newline(f)) return_0;} while (0)
 
 struct formatter;


