From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 18:22:08 -0000
Subject: LVM2 libdm/libdm-deptree.c libdm/ioctl/libdm-i ...
Message-ID: <20100325182208.18582.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 18:22:05

Modified files:
	libdm          : libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c 
	libdm/mm       : dbg_malloc.c pool-fast.c 
	libdm/regex    : matcher.c 
	liblvm         : lvm_lv.c lvm_pv.c lvm_vg.c 

Log message:
	Use INTERNAL_ERROR definition consistently in internal error messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/libdm/libdm-deptree.c	2010/01/15 16:00:23	1.71
+++ LVM2/libdm/libdm-deptree.c	2010/03/25 18:22:04	1.72
@@ -1931,7 +1931,7 @@
 	struct load_segment *seg;
 
 	if (!node->props.segment_count) {
-		log_error("Internal error: Attempt to add target area to missing segment.");
+		log_error(INTERNAL_ERROR "Attempt to add target area to missing segment.");
 		return 0;
 	}
 
@@ -2030,7 +2030,7 @@
 	}
 
 	if (!node->props.segment_count) {
-		log_error("Internal error: Attempt to add target area to missing segment.");
+		log_error(INTERNAL_ERROR "Attempt to add target area to missing segment.");
 		return 0;
 	}
 
--- LVM2/libdm/ioctl/libdm-iface.c	2010/03/23 14:38:37	1.68
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/03/25 18:22:04	1.69
@@ -691,7 +691,7 @@
 
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v1) / sizeof(*_cmd_data_v1))) {
-		log_error("Internal error: unknown device-mapper task %d",
+		log_error(INTERNAL ERROR "unknown device-mapper task %d",
 			  dmt->type);
 		goto bad;
 	}
@@ -1814,7 +1814,7 @@
 
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v4) / sizeof(*_cmd_data_v4))) {
-		log_error("Internal error: unknown device-mapper task %d",
+		log_error(INTERNAL_ERROR "unknown device-mapper task %d",
 			  dmt->type);
 		return 0;
 	}
--- LVM2/libdm/mm/dbg_malloc.c	2009/07/16 00:52:10	1.16
+++ LVM2/libdm/mm/dbg_malloc.c	2010/03/25 18:22:04	1.17
@@ -23,7 +23,7 @@
 	char *ret;
 
 	if (!str) {
-		log_error("Internal error: dm_strdup called with NULL pointer");
+		log_error(INTERNAL_ERROR "dm_strdup called with NULL pointer");
 		return NULL;
 	}
 
--- LVM2/libdm/mm/pool-fast.c	2009/04/10 09:56:59	1.7
+++ LVM2/libdm/mm/pool-fast.c	2010/03/25 18:22:04	1.8
@@ -132,7 +132,7 @@
 	}
 
 	if (!c)
-		log_error("Internal error: pool_free asked to free pointer "
+		log_error(INTERNAL_ERROR "pool_free asked to free pointer "
 			  "not in pool");
 	else
 		p->chunk = c;
--- LVM2/libdm/regex/matcher.c	2008/11/03 18:59:59	1.3
+++ LVM2/libdm/regex/matcher.c	2010/03/25 18:22:04	1.4
@@ -133,7 +133,7 @@
 			break;
 
 		default:
-			log_error("Internal error: Unknown calc node type");
+			log_error(INTERNAL_ERROR "Unknown calc node type");
 		}
 
 		/*
--- LVM2/liblvm/lvm_lv.c	2010/03/23 22:30:19	1.20
+++ LVM2/liblvm/lvm_lv.c	2010/03/25 18:22:05	1.21
@@ -44,7 +44,7 @@
 	char uuid[64] __attribute((aligned(8)));
 
 	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid))) {
-		log_error("Internal error converting uuid");
+		log_error(INTERNAL_ERROR "unable to convert uuid");
 		return NULL;
 	}
 	return strndup((const char *)uuid, 64);
--- LVM2/liblvm/lvm_pv.c	2010/02/16 00:27:02	1.9
+++ LVM2/liblvm/lvm_pv.c	2010/03/25 18:22:05	1.10
@@ -22,7 +22,7 @@
 	char uuid[64] __attribute((aligned(8)));
 
 	if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
-		log_error("Internal error converting uuid");
+		log_error(INTERNAL_ERROR "Unable to convert uuid");
 		return NULL;
 	}
 	return strndup((const char *)uuid, 64);
--- LVM2/liblvm/lvm_vg.c	2010/03/16 16:57:04	1.38
+++ LVM2/liblvm/lvm_vg.c	2010/03/25 18:22:05	1.39
@@ -333,7 +333,7 @@
 	char uuid[64] __attribute((aligned(8)));
 
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid))) {
-		log_error("Internal error converting uuid");
+		log_error(INTERNAL_ERROR "Unable to convert uuid");
 		return NULL;
 	}
 	return strndup((const char *)uuid, 64);


