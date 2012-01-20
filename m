From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Jan 2012 17:00:01 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/confi ...
Message-ID: <20120120170001.18447.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-20 17:00:00

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/config     : defaults.h 
	lib/display    : display.c 

Log message:
	Update lvdisplay to show more info about thin LVs
	
	Reformat name and path how the LV is represented with lvm1 compatible option,
	to switch to the old way - which had number of  problem - i.e. many links
	do not exist - since for private devices we are not creating them.
	Add more info about thin pools and volumes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2227&r2=1.2228
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/WHATS_NEW	2012/01/20 10:55:28	1.2227
+++ LVM2/WHATS_NEW	2012/01/20 16:59:58	1.2228
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Update lvdisplay with backward compat. config opt. lvm1_compatible_display.
   Do not report linear segtype for non-striped targets.
   Keep info about creation host and time for each logical volume.
   Make error message hit when preallocated memlock memory exceeded clearer.
--- LVM2/doc/example.conf.in	2012/01/12 01:51:56	1.41
+++ LVM2/doc/example.conf.in	2012/01/20 16:59:59	1.42
@@ -445,6 +445,11 @@
     # Specify the '--type <mirror|raid1>' option to override this default
     # setting.
     mirror_segtype_default = "mirror"
+
+    # Whether to lvdisplay LV name in lvm1 compatible format /dev/vgname/lvname
+    # Default is now to display LV name and path (if exists) separately.
+    # If the old behavior is preffered use set to 1.
+    # lvm1_compatible_display = 1
 }
 
 activation {
--- LVM2/lib/config/defaults.h	2012/01/19 15:34:32	1.93
+++ LVM2/lib/config/defaults.h	2012/01/20 16:59:59	1.94
@@ -49,6 +49,7 @@
 #define DEFAULT_PRIORITISE_WRITE_LOCKS 1
 #define DEFAULT_USE_MLOCKALL 0
 #define DEFAULT_METADATA_READ_ONLY 0
+#define DEFAULT_LVM1_COMPATIBLE_DISPLAY 0
 
 #define DEFAULT_MIRROR_SEGTYPE "mirror"
 #define DEFAULT_MIRRORLOG "disk"
--- LVM2/lib/display/display.c	2012/01/19 15:23:50	1.124
+++ LVM2/lib/display/display.c	2012/01/20 16:59:59	1.125
@@ -19,6 +19,7 @@
 #include "activate.h"
 #include "toolcontext.h"
 #include "segtype.h"
+#include "defaults.h"
 
 #define SIZE_BUF 128
 
@@ -503,7 +504,13 @@
 	char uuid[64] __attribute__((aligned(8)));
 	const char *access_str;
 	struct lv_segment *snap_seg = NULL, *mirror_seg = NULL;
+	struct lv_segment *seg = NULL;
+	int lvm1compat;
 	percent_t snap_percent;
+	int thin_data_active = 0, thin_metadata_active = 0;
+	percent_t thin_data_percent, thin_metadata_percent;
+	int thin_active = 0;
+	percent_t thin_percent;
 
 	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid)))
 		return_0;
@@ -519,13 +526,28 @@
 
 	log_print("--- Logical volume ---");
 
-	log_print("LV Name                %s%s/%s", lv->vg->cmd->dev_dir,
-		  lv->vg->name, lv->name);
-	log_print("VG Name                %s", lv->vg->name);
+	lvm1compat = find_config_tree_int(cmd, "global/lvm1_compatible_display",
+					  DEFAULT_LVM1_COMPATIBLE_DISPLAY);
 
-	log_print("LV UUID                %s", uuid);
+	if (lvm1compat) {
+		/* Note: Invisible devices do not get /dev/vg/lv */
+		log_print("LV Name                %s%s/%s",
+			  lv->vg->cmd->dev_dir, lv->vg->name, lv->name);
+	} else if (lv_is_visible(lv)) {
+		/* Thin pool does not have /dev/vg/name link */
+		if (!lv_is_thin_pool(lv))
+			log_print("LV Path                %s%s/%s",
+				  lv->vg->cmd->dev_dir,
+				  lv->vg->name, lv->name);
+		log_print("LV Name                %s", lv->name);
+	} else
+		log_print("Invisible LV Name      %s", lv->name);
 
+	log_print("VG Name                %s", lv->vg->name);
+	log_print("LV UUID                %s", uuid);
 	log_print("LV Write Access        %s", access_str);
+	log_print("LV Creation host, time %s, %s",
+		  lv_host_dup(cmd->mem, lv), lv_time_dup(cmd->mem, lv));
 
 	if (lv_is_origin(lv)) {
 		log_print("LV snapshot status     source of");
@@ -537,10 +559,15 @@
 							       &snap_percent)))
 				if (snap_percent == PERCENT_INVALID)
 					snap_active = 0;
-			log_print("                       %s%s/%s [%s]",
-				  lv->vg->cmd->dev_dir, lv->vg->name,
-				  snap_seg->cow->name,
-				  snap_active ? "active" : "INACTIVE");
+			if (lvm1compat)
+				log_print("                       %s%s/%s [%s]",
+					  lv->vg->cmd->dev_dir, lv->vg->name,
+					  snap_seg->cow->name,
+					  snap_active ? "active" : "INACTIVE");
+			else
+				log_print("                       %s [%s]",
+					  snap_seg->cow->name,
+					  snap_active ? "active" : "INACTIVE");
 		}
 		snap_seg = NULL;
 	} else if ((snap_seg = find_cow(lv))) {
@@ -550,25 +577,39 @@
 			if (snap_percent == PERCENT_INVALID)
 				snap_active = 0;
 
-		log_print("LV snapshot status     %s destination for %s%s/%s",
-			  snap_active ? "active" : "INACTIVE",
-			  lv->vg->cmd->dev_dir, lv->vg->name,
-			  snap_seg->origin->name);
+		if (lvm1compat)
+			log_print("LV snapshot status     %s destination for %s%s/%s",
+				  snap_active ? "active" : "INACTIVE",
+				  lv->vg->cmd->dev_dir, lv->vg->name,
+				  snap_seg->origin->name);
+		else
+			log_print("LV snapshot status     %s destination for %s",
+				  snap_active ? "active" : "INACTIVE",
+				  snap_seg->origin->name);
 	}
 
 	if (lv_is_thin_volume(lv)) {
-		log_print("LV Thin pool           %s%s/%s", lv->vg->cmd->dev_dir,
-			  lv->vg->name, first_seg(lv)->pool_lv->name);
+		seg = first_seg(lv);
+		log_print("LV Pool name           %s", seg->pool_lv->name);
+		if (seg->origin)
+			log_print("LV Thin origin name    %s",
+				  seg->origin->name);
+		if (inkernel)
+			thin_active = lv_thin_percent(lv, 0, &thin_percent);
 	} else if (lv_is_thin_pool(lv)) {
+		if (inkernel) {
+			thin_data_active = lv_thin_pool_percent(lv, 0, &thin_data_percent);
+			thin_metadata_active = lv_thin_pool_percent(lv, 1, &thin_metadata_percent);
+		}
 		/* FIXME: display thin_pool targets transid for activated LV as well */
-		log_print("LV Thin transaction ID %" PRIu64,
-			  first_seg(lv)->transaction_id);
-		log_print("LV Thin metadata       %s%s/%s", lv->vg->cmd->dev_dir,
-			  lv->vg->name, first_seg(lv)->metadata_lv->name);
-		log_print("LV Thin data pool      %s%s/%s", lv->vg->cmd->dev_dir,
-			  lv->vg->name, seg_lv(first_seg(lv), 0)->name);
+		seg = first_seg(lv);
+		log_print("LV Pool transaction ID %" PRIu64, seg->transaction_id);
+		log_print("LV Pool metadata       %s", seg->metadata_lv->name);
+		log_print("LV Pool data           %s", seg_lv(seg, 0)->name);
+		log_print("LV Pool chunk size     %s",
+			  display_size(cmd, seg->data_block_size));
 		log_print("LV Zero new blocks     %s",
-			  first_seg(lv)->zero_new_blocks ? "yes" : "no");
+			  seg->zero_new_blocks ? "yes" : "no");
 	}
 
 	if (inkernel && info.suspended)
@@ -588,6 +629,18 @@
 		  display_size(cmd,
 			       snap_seg ? snap_seg->origin->size : lv->size));
 
+	if (thin_data_active)
+		log_print("Allocated pool data    %.2f%%",
+			  percent_to_float(thin_data_percent));
+
+	if (thin_metadata_active)
+		log_print("Allocated metadata     %.2f%%",
+			  percent_to_float(thin_metadata_percent));
+
+	if (thin_active)
+		log_print("Mapped size            %.2f%%",
+			  percent_to_float(thin_percent));
+
 	log_print("Current LE             %u",
 		  snap_seg ? snap_seg->origin->le_count : lv->le_count);
 
@@ -597,7 +650,7 @@
 		log_print("COW-table LE           %u", lv->le_count);
 
 		if (snap_active)
-			log_print("Allocated to snapshot  %.2f%% ",
+			log_print("Allocated to snapshot  %.2f%%",
 				  percent_to_float(snap_percent));
 
 		log_print("Snapshot chunk size    %s",
@@ -605,7 +658,7 @@
 	}
 
 	if (lv->status & MIRRORED) {
- 		mirror_seg = first_seg(lv);
+		mirror_seg = first_seg(lv);
 		log_print("Mirrored volumes       %" PRIu32, mirror_seg->area_count);
 		if (lv->status & CONVERTING)
 			log_print("LV type        Mirror undergoing conversion");


