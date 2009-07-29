From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jul 2009 16:47:54 -0000
Subject: LVM2/liblvm lvm_lv.c
Message-ID: <20090729164754.7737.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-29 16:47:54

Modified files:
	liblvm         : lvm_lv.c 

Log message:
	Remove unneeded struct on return from lvm_lv_create_linear.
	
	Results in compile warning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/liblvm/lvm_lv.c	2009/07/29 13:26:01	1.13
+++ LVM2/liblvm/lvm_lv.c	2009/07/29 16:47:53	1.14
@@ -120,7 +120,7 @@
 	lvl = find_lv_in_vg(vg, name);
 	if (!lvl)
 		return NULL;
-	return (struct lv_t *) lvl->lv;
+	return (lv_t *) lvl->lv;
 }
 
 /*


