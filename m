From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 18:19:33 -0000
Subject: LVM2/libdm libdm-string.c
Message-ID: <20120223181933.30895.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 18:19:32

Modified files:
	libdm          : libdm-string.c 

Log message:
	Missed dm_free in last commit

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/libdm/libdm-string.c	2012/02/23 18:05:12	1.19
+++ LVM2/libdm/libdm-string.c	2012/02/23 18:19:32	1.20
@@ -161,6 +161,7 @@
 			dm_free(buf);
 			return -1;
 		}
+		dm_free(buf);
 	} else
 		*result = buf;
 


