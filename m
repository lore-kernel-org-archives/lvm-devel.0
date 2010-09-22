From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Sep 2010 01:50:38 -0000
Subject: LVM2/lib/filters filter-md.c
Message-ID: <20100922015038.11915.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-09-22 01:50:38

Modified files:
	lib/filters    : filter-md.c 

Log message:
	Fix name in msg in last checkin.
	
	(The problem the last checkin addressed was a segfault in 'pvs -a' if .cache
	didn't contain every PV in a VG.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-md.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/lib/filters/filter-md.c	2010/09/22 01:36:14	1.10
+++ LVM2/lib/filters/filter-md.c	2010/09/22 01:50:38	1.11
@@ -46,7 +46,7 @@
 static void _destroy(struct dev_filter *f)
 {
 	if (f->use_count)
-		log_error(INTERNAL_ERROR "Destroying sysfs filter while in use %u times.", f->use_count);
+		log_error(INTERNAL_ERROR "Destroying md filter while in use %u times.", f->use_count);
 
 	dm_free(f);
 }


