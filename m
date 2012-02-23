From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 22:31:23 -0000
Subject: LVM2/lib/metadata lv.c
Message-ID: <20120223223123.10139.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 22:31:23

Modified files:
	lib/metadata   : lv.c 

Log message:
	Add explicit cast for time() ret value
	
	To keep all numbers with same sign

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/lib/metadata/lv.c	2012/02/13 11:25:56	1.37
+++ LVM2/lib/metadata/lv.c	2012/02/23 22:31:23	1.38
@@ -529,7 +529,7 @@
 	}
 
 	lv->hostname = hn;
-	lv->timestamp = timestamp ? : time(NULL);
+	lv->timestamp = timestamp ? : (uint64_t) time(NULL);
 
 	return 1;
 }


