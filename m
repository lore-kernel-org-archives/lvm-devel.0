From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Mar 2009 15:42:14 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import_vsn1.c
Message-ID: <20090309154214.20285.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-09 15:42:13

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import_vsn1.c 

Log message:
	Fix error messages when PV uuid or pe_start reading fails.
	
	Author: Takahiro Yasui <tyasui@redhat.com>
	Committer: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1064&r2=1.1065
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2009/03/06 16:19:52	1.1064
+++ LVM2/WHATS_NEW	2009/03/09 15:42:10	1.1065
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix error messages when PV uuid or pe_start reading fails.
   Rename liblvm.a to liblvm-internal.a and build new application library.
   Flush memory pool and fix locking in clvmd refresh and backup command.
   Fix unlocks in clvmd-corosync. Broken in 2.02.45.
--- LVM2/lib/format_text/import_vsn1.c	2008/11/03 22:14:28	1.55
+++ LVM2/lib/format_text/import_vsn1.c	2009/03/09 15:42:12	1.56
@@ -179,7 +179,7 @@
 	}
 
 	if (!_read_id(&pv->id, pvn, "id")) {
-		log_error("Couldn't read uuid for volume group.");
+		log_error("Couldn't read uuid for physical volume.");
 		return 0;
 	}
 
@@ -213,7 +213,7 @@
 	_read_int64(pvn, "dev_size", &pv->size);
 
 	if (!_read_int64(pvn, "pe_start", &pv->pe_start)) {
-		log_error("Couldn't read extent size for volume group.");
+		log_error("Couldn't read extent size for physical volume.");
 		return 0;
 	}
 


