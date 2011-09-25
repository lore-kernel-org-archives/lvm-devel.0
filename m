From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Sep 2011 19:42:45 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20110925194245.17935.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-25 19:42:45

Modified files:
	libdm          : libdm-config.c 

Log message:
	Add backtrace when allocation fails for _type

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/libdm/libdm-config.c	2011/09/25 19:41:27	1.10
+++ LVM2/libdm/libdm-config.c	2011/09/25 19:42:45	1.11
@@ -605,7 +605,8 @@
 		}
 
 	} else
-		h = _type(p);
+		if (!(h = _type(p)))
+			return_NULL;
 
 	return h;
 }


