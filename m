From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 22:35:36 -0000
Subject: LVM2/lib/format_text export.c
Message-ID: <20120125223536.22434.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 22:35:36

Modified files:
	lib/format_text: export.c 

Log message:
	Instrument code that pointer are already released
	
	Set pointers to NULL since on the function exit they are no longer valid.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/lib/format_text/export.c	2012/01/19 15:31:45	1.85
+++ LVM2/lib/format_text/export.c	2012/01/25 22:35:36	1.86
@@ -757,11 +757,15 @@
 	r = 1;
 
       out:
-	if (f->mem)
+	if (f->mem) {
 		dm_pool_destroy(f->mem);
+		f->mem = NULL;
+	}
 
-	if (f->pv_names)
+	if (f->pv_names) {
 		dm_hash_destroy(f->pv_names);
+		f->pv_names = NULL;
+	}
 
 	return r;
 }


