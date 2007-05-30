From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 May 2007 20:43:09 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c lib/dis ...
Message-ID: <20070530204309.2793.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-05-30 20:43:09

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c display.h 
	tools          : pvdisplay.c 

Log message:
	Add --maps to pvdisplay.
	Modified original patch from David Robinson <zxvdr.au@gmail.com>.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.621&r2=1.622
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/WHATS_NEW	2007/05/22 02:52:57	1.621
+++ LVM2/WHATS_NEW	2007/05/30 20:43:08	1.622
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Add --maps feature to pvdisplay, showing PE to LE mappings.
   Fix vgcfgrestore man pg to show mandatory VG name and remove LVM1 options.
   Fix vgrename man page to include UUID and be consistent with lvrename.
   Add (experimental) OpenAIS support to clvmd.
--- LVM2/lib/display/display.c	2006/11/30 23:11:40	1.70
+++ LVM2/lib/display/display.c	2007/05/30 20:43:09	1.71
@@ -258,6 +258,36 @@
 	return;
 }
 
+void pvdisplay_segments(struct physical_volume *pv)
+{
+	struct pv_segment *seg;
+
+	log_print("--- Segments ---");
+
+	list_iterate_items(seg, &pv->segments) {
+		if (seg->len == pv->pe_count)
+			continue;
+		log_print("Physical extent %u to %u:",
+			  seg->pe, seg->pe + seg->len - 1);
+
+		if (seg->lvseg) {
+			log_print("  Type\t\t%s",
+				  seg->lvseg->segtype->ops->name(seg->lvseg));
+			log_print("  Logical volume\t%s%s/%s",
+				  seg->lvseg->lv->vg->cmd->dev_dir,
+				  seg->lvseg->lv->vg->name,
+				  seg->lvseg->lv->name);
+			log_print("  Logical extents\t%d to %d",
+				  seg->lvseg->le, seg->lvseg->le +
+				  seg->lvseg->len - 1);
+		} else
+			log_print("  FREE");
+	}
+
+	log_print(" ");
+	return;
+}
+
 /* FIXME Include label fields */
 void pvdisplay_full(struct cmd_context *cmd, struct physical_volume *pv,
 		    void *handle __attribute((unused)))
--- LVM2/lib/display/display.h	2006/05/09 21:23:50	1.16
+++ LVM2/lib/display/display.h	2007/05/30 20:43:09	1.17
@@ -31,6 +31,7 @@
 void display_stripe(const struct lv_segment *seg, uint32_t s, const char *pre);
 
 void pvdisplay_colons(struct physical_volume *pv);
+void pvdisplay_segments(struct physical_volume *pv);
 void pvdisplay_full(struct cmd_context *cmd, struct physical_volume *pv,
 		    void *handle);
 int pvdisplay_short(struct cmd_context *cmd, struct volume_group *vg,
--- LVM2/tools/pvdisplay.c	2006/10/16 16:29:40	1.25
+++ LVM2/tools/pvdisplay.c	2007/05/30 20:43:09	1.26
@@ -71,8 +71,8 @@
 
 	pvdisplay_full(cmd, pv, handle);
 
-	if (!arg_count(cmd, maps_ARG))
-		goto out;
+	if (arg_count(cmd, maps_ARG))
+		pvdisplay_segments(pv);
 
 out:
         if (pv->vg_name)


