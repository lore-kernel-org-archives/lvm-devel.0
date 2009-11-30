From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:04 +0100
Subject: [PATCH 04/23] Export outsz() and outhnt() for modules
In-Reply-To: <1259581043-15308-4-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-5-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding macro outsz() for out_size() and outhnt() for out_hint()
that checks for error in a similar way as outf() does for out_text()

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/export.c      |   23 +++++++++--------------
 lib/format_text/text_export.h |    2 ++
 2 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 15439fd..8010121 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -386,9 +386,8 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 	if (vg->system_id && *vg->system_id)
 		outf(f, "system_id = \"%s\"", vg->system_id);
 
-	if (!out_size(f, (uint64_t) vg->extent_size, "extent_size = %u",
-		      vg->extent_size))
-		return_0;
+	outsz(f, (uint64_t) vg->extent_size, "extent_size = %u",
+	      vg->extent_size);
 	outf(f, "max_lv = %u", vg->max_lv);
 	outf(f, "max_pv = %u", vg->max_pv);
 
@@ -453,9 +452,8 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 			return 0;
 		}
 
-		if (!out_hint(f, "device = \"%s\"",
-			      escape_double_quotes(buf, pv_dev_name(pv))))
-			return_0;
+		outhnt(f, "device = \"%s\"",
+		       escape_double_quotes(buf, pv_dev_name(pv)));
 		outnl(f);
 
 		if (!_print_flag_config(f, pv->status, PV_FLAGS))
@@ -467,13 +465,11 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 			outf(f, "tags = %s", buffer);
 		}
 
-		if (!out_size(f, pv->size, "dev_size = %" PRIu64, pv->size))
-			return_0;
+		outsz(f, pv->size, "dev_size = %" PRIu64, pv->size);
 
 		outf(f, "pe_start = %" PRIu64, pv->pe_start);
-		if (!out_size(f, vg->extent_size * (uint64_t) pv->pe_count,
-			      "pe_count = %u", pv->pe_count))
-			return_0;
+		outsz(f, vg->extent_size * (uint64_t) pv->pe_count,
+		      "pe_count = %u", pv->pe_count);
 
 		_dec_indent(f);
 		outf(f, "}");
@@ -493,9 +489,8 @@ static int _print_segment(struct formatter *f, struct volume_group *vg,
 	_inc_indent(f);
 
 	outf(f, "start_extent = %u", seg->le);
-	if (!out_size(f, (uint64_t) seg->len * vg->extent_size,
-		      "extent_count = %u", seg->len))
-		return_0;
+	outsz(f, (uint64_t) seg->len * vg->extent_size,
+	      "extent_count = %u", seg->len);
 
 	outnl(f);
 	outf(f, "type = \"%s\"", seg->segtype->name);
diff --git a/lib/format_text/text_export.h b/lib/format_text/text_export.h
index cdba82f..a452439 100644
--- a/lib/format_text/text_export.h
+++ b/lib/format_text/text_export.h
@@ -16,6 +16,8 @@
 #ifndef _LVM_TEXT_EXPORT_H
 #define _LVM_TEXT_EXPORT_H
 
+#define outsz(args...) do {if (!out_size(args)) return_0;} while (0)
+#define outhnt(args...) do {if (!out_hint(args)) return_0;} while (0)
 #define outf(args...) do {if (!out_text(args)) return_0;} while (0)
 #define outnl(f) do {if (!out_newline(f)) return_0;} while (0)
 
-- 
1.6.5.3


