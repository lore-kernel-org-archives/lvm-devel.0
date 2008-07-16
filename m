From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jul 2008 10:46:12 -0000
Subject: LVM2 ./WHATS_NEW tools/pvchange.c
Message-ID: <20080716104612.25412.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-16 10:46:12

Modified files:
	.              : WHATS_NEW 
	tools          : pvchange.c 

Log message:
	Fix pvchange -M1 -u to preserve existing extent locations when there's a VG.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.929&r2=1.930
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2008/07/15 00:25:51	1.929
+++ LVM2/WHATS_NEW	2008/07/16 10:46:12	1.930
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Fix pvchange -M1 -u to preserve existing extent locations when there's a VG.
   Cease recognising snapshot-in-use percentages returned by early devt kernels.
   Add backward-compatible flags field to on-disk format_text metadata.
   Fix dmeventd monitoring libraries to link against liblvm2cmd again. (2.02.39)
--- LVM2/tools/pvchange.c	2008/02/06 15:47:28	1.59
+++ LVM2/tools/pvchange.c	2008/07/16 10:46:12	1.60
@@ -26,6 +26,9 @@
 	struct list mdas;
 	uint64_t sector;
 	uint32_t orig_pe_alloc_count;
+	/* FIXME Next three only required for format1. */
+	uint32_t orig_pe_count, orig_pe_size;
+	uint64_t orig_pe_start;
 
 	const char *pv_name = pv_dev_name(pv);
 	const char *tag = NULL;
@@ -171,6 +174,12 @@
 		if (!is_orphan(pv)) {
 			orig_vg_name = pv_vg_name(pv);
 			orig_pe_alloc_count = pv_pe_alloc_count(pv);
+
+			/* FIXME format1 pv_write doesn't preserve these. */
+			orig_pe_size = pv_pe_size(pv);
+			orig_pe_start = pv_pe_start(pv);
+			orig_pe_count = pv_pe_count(pv);
+
 			pv->vg_name = pv->fmt->orphan_vg_name;
 			pv->pe_alloc_count = 0;
 			if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
@@ -181,6 +190,10 @@
 			}
 			pv->vg_name = orig_vg_name;
 			pv->pe_alloc_count = orig_pe_alloc_count;
+
+			pv->pe_size = orig_pe_size;
+			pv->pe_start = orig_pe_start;
+			pv->pe_count = orig_pe_count;
 		}
 	}
 


