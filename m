From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Mar 2011 23:01:08 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20110313230108.13989.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-13 23:01:08

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Use proper size of strncpy
	
	Avoid reading extra character if we expect to have there '\0'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/lib/cache/lvmcache.c	2011/03/11 15:08:31	1.106
+++ LVM2/lib/cache/lvmcache.c	2011/03/13 23:01:08	1.107
@@ -1287,7 +1287,7 @@
 		return NULL;
 	}
 
-	strncpy(pvid_s, pvid, sizeof(pvid_s));
+	strncpy(pvid_s, pvid, sizeof(pvid_s) - 1);
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
 
 	if (!(existing = info_from_pvid(pvid_s, 0)) &&


