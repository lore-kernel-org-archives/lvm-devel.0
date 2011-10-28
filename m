From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:12:56 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20111028201256.26622.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:12:55

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Add last_seg
	
	Implement a function to return the last segment in a LV.
	
	Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2173&r2=1.2174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.216&r2=1.217
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.470&r2=1.471

--- LVM2/WHATS_NEW	2011/10/28 20:06:49	1.2173
+++ LVM2/WHATS_NEW	2011/10/28 20:12:54	1.2174
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add last_seg(lv) internal function.
   Support empty string for log/prefix.
   Fix regression that allowed mirrored logs for cluster mirrors.
   Don't print char type[8] as a plain string in pvck PV type.
--- LVM2/lib/metadata/metadata-exported.h	2011/10/21 11:38:35	1.216
+++ LVM2/lib/metadata/metadata-exported.h	2011/10/28 20:12:55	1.217
@@ -660,6 +660,7 @@
 				  const char *pvid);
 /* Find LV segment containing given LE */
 struct lv_segment *first_seg(const struct logical_volume *lv);
+struct lv_segment *last_seg(const struct logical_volume *lv);
 
 
 /*
--- LVM2/lib/metadata/metadata.c	2011/10/24 10:24:40	1.470
+++ LVM2/lib/metadata/metadata.c	2011/10/28 20:12:55	1.471
@@ -1906,6 +1906,16 @@
 	return NULL;
 }
 
+struct lv_segment *last_seg(const struct logical_volume *lv)
+{
+       struct lv_segment *seg;
+
+       dm_list_iterate_back_items(seg, &lv->segments)
+               return seg;
+
+       return NULL;
+}
+
 int vg_remove_mdas(struct volume_group *vg)
 {
 	struct metadata_area *mda;


