From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Jan 2012 11:01:57 -0000
Subject: LVM2/lib/device dev-cache.c
Message-ID: <20120120110157.3293.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-20 11:01:57

Modified files:
	lib/device     : dev-cache.c 

Log message:
	Minor cleanup
	
	Simplier and more readable char pointer math.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/lib/device/dev-cache.c	2011/12/21 13:21:09	1.69
+++ LVM2/lib/device/dev-cache.c	2012/01/20 11:01:56	1.70
@@ -256,8 +256,8 @@
 
 	strncpy(p0, path0, PATH_MAX);
 	strncpy(p1, path1, PATH_MAX);
-	s0 = &p0[0] + 1;
-	s1 = &p1[0] + 1;
+	s0 = p0 + 1;
+	s1 = p1 + 1;
 
 	/*
 	 * If we reach here, both paths are the same length.


