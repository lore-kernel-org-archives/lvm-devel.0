From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:30 +0000 (GMT)
Subject: main - cleanup: easier print of historical lv
Message-ID: <20210310003630.BB7E8385802B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c05077f4d4534fd0f63a9642b596262843f81e30
Commit:        c05077f4d4534fd0f63a9642b596262843f81e30
Parent:        177b63becc8ac0c0a9d74132f419f9ec38d4323d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 12:30:25 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:11:52 2021 +0100

cleanup: easier print of historical lv

Drop unneeded macros.
---
 lib/format_text/export.c      | 41 +++++++++++++++++++++++------------------
 lib/format_text/text_export.h |  2 --
 2 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 2253a80af..6ece94042 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -880,45 +880,50 @@ bad:
 	return 0;
 }
 
-static int _print_historical_lv(struct formatter *f, struct historical_logical_volume *hlv)
+static int _print_historical_lv_with_descendants(struct formatter *f, struct historical_logical_volume *hlv,
+						 char *descendants_buffer)
 {
 	char buffer[40];
-	char *descendants_buffer = NULL;
-	int r = 0;
 
 	if (!id_write_format(&hlv->lvid.id[1], buffer, sizeof(buffer)))
-		goto_out;
-
-	if (!_alloc_printed_indirect_descendants(&hlv->indirect_glvs, &descendants_buffer))
-		goto_out;
+		return_0;
 
-	outnlgo(f);
-	outfgo(f, "%s {", hlv->name);
+	outnl(f);
+	outf(f, "%s {", hlv->name);
 	_inc_indent(f);
 
-	outfgo(f, "id = \"%s\"", buffer);
+	outf(f, "id = \"%s\"", buffer);
 
 	if (!_print_timestamp(f, "creation_time", hlv->timestamp, buffer, sizeof(buffer)))
-		goto_out;
+		return_0;
 
 	if (!_print_timestamp(f, "removal_time", hlv->timestamp_removed, buffer, sizeof(buffer)))
-		goto_out;
+		return_0;
 
 	if (hlv->indirect_origin) {
 		if (hlv->indirect_origin->is_historical)
-			outfgo(f, "origin = \"%s%s\"", HISTORICAL_LV_PREFIX, hlv->indirect_origin->historical->name);
+			outf(f, "origin = \"%s%s\"", HISTORICAL_LV_PREFIX, hlv->indirect_origin->historical->name);
 		else
-			outfgo(f, "origin = \"%s\"", hlv->indirect_origin->live->name);
+			outf(f, "origin = \"%s\"", hlv->indirect_origin->live->name);
 	}
 
 	if (descendants_buffer)
-		outfgo(f, "descendants = %s", descendants_buffer);
+		outf(f, "descendants = %s", descendants_buffer);
 
 	_dec_indent(f);
-	outfgo(f, "}");
+	outf(f, "}");
+
+	return 1;
+}
+
+static int _print_historical_lv(struct formatter *f, struct historical_logical_volume *hlv)
+{
+	char *descendants_buffer = NULL;
+	int r = 0;
+
+	if (_alloc_printed_indirect_descendants(&hlv->indirect_glvs, &descendants_buffer))
+		r = _print_historical_lv_with_descendants(f, hlv, descendants_buffer);
 
-	r = 1;
-out:
 	free(descendants_buffer);
 
 	return r;
diff --git a/lib/format_text/text_export.h b/lib/format_text/text_export.h
index c20c234d5..33c136bb3 100644
--- a/lib/format_text/text_export.h
+++ b/lib/format_text/text_export.h
@@ -20,9 +20,7 @@
 #define outhint(args...) do {if (!out_hint(args)) return_0;} while (0)
 #define outfc(args...) do {if (!out_text_with_comment(args)) return_0;} while (0)
 #define outf(args...) do {if (!out_text(args)) return_0;} while (0)
-#define outfgo(args...) do {if (!out_text(args)) goto_out;} while (0)
 #define outnl(f) do {if (!out_newline(f)) return_0;} while (0)
-#define outnlgo(f) do {if (!out_newline(f)) goto_out;} while (0)
 
 struct formatter;
 struct lv_segment;


