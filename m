From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 23 Jun 2011 14:01:00 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20110623140100.23242.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-06-23 14:00:59

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c mirror.c 

Log message:
	Fix to preserve exclusive activation of mirror while up-converting.
	
	When an LVM mirror is up-converted (an additional image added), it creates
	a temporary mirror stack.  The lower-level mirror in the stack that is
	created was not being activated exclusively - violating the exclusive nature
	of the original mirror.  We now check for exclusive activation of a mirror
	before converting it, and if found, we ensure that the temporary mirror
	is also exclusively activated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2025&r2=1.2026
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.263&r2=1.264
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156

--- LVM2/WHATS_NEW	2011/06/23 10:53:24	1.2025
+++ LVM2/WHATS_NEW	2011/06/23 14:00:58	1.2026
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Fix to preserve exclusive activation of mirror while up-converting.
   Reject allocation if number of extents is not divisible by area count.
   Fix issue preventing cluster mirror creation.
   Disable udev fallback by default and add activation/udev_fallback to lvm.conf.
--- LVM2/lib/metadata/lv_manip.c	2011/06/23 10:53:24	1.263
+++ LVM2/lib/metadata/lv_manip.c	2011/06/23 14:00:58	1.264
@@ -3103,11 +3103,13 @@
 					   uint64_t status,
 					   const char *layer_suffix)
 {
+	int r;
 	struct logical_volume *layer_lv;
 	char *name;
 	size_t len;
 	struct segment_type *segtype;
 	struct lv_segment *mapseg;
+	unsigned exclusive = 0;
 
 	/* create an empty layer LV */
 	len = strlen(lv_where->name) + 32;
@@ -3129,6 +3131,9 @@
 		return NULL;
 	}
 
+	if (lv_is_active_exclusive_locally(lv_where))
+		exclusive = 1;
+
 	if (lv_is_active(lv_where) && strstr(name, "_mimagetmp")) {
 		log_very_verbose("Creating transient LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
 
@@ -3150,8 +3155,15 @@
 			return NULL;
 		}
 
-		if (!activate_lv(cmd, layer_lv)) {
-			log_error("Failed to resume transient error LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
+		if (exclusive)
+			r = activate_lv_excl(cmd, layer_lv);
+		else
+			r = activate_lv(cmd, layer_lv);
+
+		if (!r) {
+			log_error("Failed to resume transient LV"
+				  " %s for mirror conversion in VG %s.",
+				  name, lv_where->vg->name);
 			return NULL;
 		}
 	}
--- LVM2/lib/metadata/mirror.c	2011/06/22 21:31:21	1.155
+++ LVM2/lib/metadata/mirror.c	2011/06/23 14:00:59	1.156
@@ -419,8 +419,13 @@
 		}
 	}
 
-	if (!activate_lv(cmd, lv))
-		return_0;
+	if (lv_is_active_exclusive_locally(lv)) {
+		if (!activate_lv_excl(cmd, lv))
+			return_0;
+	} else {
+		if (!activate_lv(cmd, lv))
+			return_0;
+	}
 
 	if (!deactivate_lv(cmd, lv))
 		return_0;


