From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:17:46 -0000
Subject: LVM2/lib/format_text import_vsn1.c
Message-ID: <20120119151746.24189.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:17:46

Modified files:
	lib/format_text: import_vsn1.c 

Log message:
	Rename internal macro to match signess
	
	Since _read_int64 called dm_config_get_uint64, rename it to
	less confusing _read_uint64.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/lib/format_text/import_vsn1.c	2011/12/21 12:49:00	1.96
+++ LVM2/lib/format_text/import_vsn1.c	2012/01/19 15:17:46	1.97
@@ -39,7 +39,7 @@
 #define _read_uint32(root, path, result) \
 	dm_config_get_uint32(root, path, result)
 
-#define _read_int64(root, path, result) \
+#define _read_uint64(root, path, result) \
 	dm_config_get_uint64(root, path, result)
 
 /*
@@ -216,9 +216,9 @@
 		pv->status |= MISSING_PV;
 
 	/* Late addition */
-	_read_int64(pvn, "dev_size", &pv->size);
+	_read_uint64(pvn, "dev_size", &pv->size);
 
-	if (!_read_int64(pvn, "pe_start", &pv->pe_start)) {
+	if (!_read_uint64(pvn, "pe_start", &pv->pe_start)) {
 		log_error("Couldn't read extent size for physical volume.");
 		return 0;
 	}


