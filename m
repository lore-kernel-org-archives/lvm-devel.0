From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jan 2010 14:40:47 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/export.c lib/ ...
Message-ID: <20100107144047.26345.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-07 14:40:46

Modified files:
	.              : WHATS_NEW 
	lib/format_text: export.c text_export.h 

Log message:
	Add macros outsize() for out_size() and outhint() for out_hint() that check
	for errors in a similar way as outf() for out_text().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1368&r2=1.1369
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_export.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2010/01/07 14:37:11	1.1368
+++ LVM2/WHATS_NEW	2010/01/07 14:40:46	1.1369
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Add macros outsize() and outhint().
   Use offsetof() macro for FIELD() macro in lib/report/report.c.
   Rename mirror_device_fault_policy to mirror_image_fault policy.
   Remove empty PV devices if lvconvert --repair is using defined policies.
--- LVM2/lib/format_text/export.c	2009/12/16 19:22:12	1.73
+++ LVM2/lib/format_text/export.c	2010/01/07 14:40:46	1.74
@@ -386,9 +386,8 @@
 	if (vg->system_id && *vg->system_id)
 		outf(f, "system_id = \"%s\"", vg->system_id);
 
-	if (!out_size(f, (uint64_t) vg->extent_size, "extent_size = %u",
-		      vg->extent_size))
-		return_0;
+	outsize(f, (uint64_t) vg->extent_size, "extent_size = %u",
+		vg->extent_size);
 	outf(f, "max_lv = %u", vg->max_lv);
 	outf(f, "max_pv = %u", vg->max_pv);
 
@@ -453,9 +452,8 @@
 			return 0;
 		}
 
-		if (!out_hint(f, "device = \"%s\"",
-			      escape_double_quotes(buf, pv_dev_name(pv))))
-			return_0;
+		outhint(f, "device = \"%s\"",
+			escape_double_quotes(buf, pv_dev_name(pv)));
 		outnl(f);
 
 		if (!_print_flag_config(f, pv->status, PV_FLAGS))
@@ -467,13 +465,11 @@
 			outf(f, "tags = %s", buffer);
 		}
 
-		if (!out_size(f, pv->size, "dev_size = %" PRIu64, pv->size))
-			return_0;
+		outsize(f, pv->size, "dev_size = %" PRIu64, pv->size);
 
 		outf(f, "pe_start = %" PRIu64, pv->pe_start);
-		if (!out_size(f, vg->extent_size * (uint64_t) pv->pe_count,
-			      "pe_count = %u", pv->pe_count))
-			return_0;
+		outsize(f, vg->extent_size * (uint64_t) pv->pe_count,
+			"pe_count = %u", pv->pe_count);
 
 		_dec_indent(f);
 		outf(f, "}");
@@ -493,9 +489,8 @@
 	_inc_indent(f);
 
 	outf(f, "start_extent = %u", seg->le);
-	if (!out_size(f, (uint64_t) seg->len * vg->extent_size,
-		      "extent_count = %u", seg->len))
-		return_0;
+	outsize(f, (uint64_t) seg->len * vg->extent_size,
+		"extent_count = %u", seg->len);
 
 	outnl(f);
 	outf(f, "type = \"%s\"", seg->segtype->name);
--- LVM2/lib/format_text/text_export.h	2009/11/03 11:00:46	1.6
+++ LVM2/lib/format_text/text_export.h	2010/01/07 14:40:46	1.7
@@ -16,6 +16,8 @@
 #ifndef _LVM_TEXT_EXPORT_H
 #define _LVM_TEXT_EXPORT_H
 
+#define outsize(args...) do {if (!out_size(args)) return_0;} while (0)
+#define outhint(args...) do {if (!out_hint(args)) return_0;} while (0)
 #define outf(args...) do {if (!out_text(args)) return_0;} while (0)
 #define outnl(f) do {if (!out_newline(f)) return_0;} while (0)
 


