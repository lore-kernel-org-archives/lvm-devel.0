From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:57:44 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20120301215744.20197.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:57:43

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Explicitely ignore fail from this label_read

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/lib/cache/lvmcache.c	2012/02/28 18:20:17	1.131
+++ LVM2/lib/cache/lvmcache.c	2012/03/01 21:57:43	1.132
@@ -498,7 +498,7 @@
 
 	dm_list_iterate_safe(devh, tmp, &devs) {
 		devl = dm_list_item(devh, struct device_list);
-		label_read(devl->dev, &label, UINT64_C(0));
+		(void) label_read(devl->dev, &label, UINT64_C(0));
 		dm_list_del(&devl->list);
 		dm_free(devl);
 	}


