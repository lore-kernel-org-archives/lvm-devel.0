From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 May 2016 08:19:39 +0000 (UTC)
Subject: master - coverity: fix possible resource leak of descendants_buffer in _print_historical_lv fn
Message-ID: <20160531081939.8A9C661EEF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02d67848eb994c19c6ff2050196585fb763c83cb
Commit:        02d67848eb994c19c6ff2050196585fb763c83cb
Parent:        cfe7d2368cfaf9744e4fc82d781b3815b5c57155
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 31 09:36:40 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 31 09:36:58 2016 +0200

coverity: fix possible resource leak of descendants_buffer in _print_historical_lv fn

---
 lib/format_text/export.c      |    2 +-
 lib/format_text/text_export.h |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index a762c74..810c932 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -858,7 +858,7 @@ static int _print_historical_lv(struct formatter *f, struct historical_logical_v
 	if (!_alloc_printed_indirect_descendants(&hlv->indirect_glvs, &descendants_buffer))
 		goto_out;
 
-	outnl(f);
+	outnlgo(f);
 	outfgo(f, "%s {", hlv->name);
 	_inc_indent(f);
 
diff --git a/lib/format_text/text_export.h b/lib/format_text/text_export.h
index 377ee93..c20c234 100644
--- a/lib/format_text/text_export.h
+++ b/lib/format_text/text_export.h
@@ -22,6 +22,7 @@
 #define outf(args...) do {if (!out_text(args)) return_0;} while (0)
 #define outfgo(args...) do {if (!out_text(args)) goto_out;} while (0)
 #define outnl(f) do {if (!out_newline(f)) return_0;} while (0)
+#define outnlgo(f) do {if (!out_newline(f)) goto_out;} while (0)
 
 struct formatter;
 struct lv_segment;


