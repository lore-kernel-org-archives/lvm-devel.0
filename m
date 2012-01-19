From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:16:40 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20120119151640.23004.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:16:39

Modified files:
	libdm          : libdm-config.c 

Log message:
	Update for gcc old-style

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/libdm/libdm-config.c	2011/12/21 12:47:45	1.19
+++ LVM2/libdm/libdm-config.c	2012/01/19 15:16:39	1.20
@@ -89,7 +89,7 @@
 	return !(*str || (b != e));
 }
 
-struct dm_config_tree *dm_config_create()
+struct dm_config_tree *dm_config_create(void)
 {
 	struct dm_config_tree *cft;
 	struct dm_pool *mem = dm_pool_create("config", 10 * 1024);


