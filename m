From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Sep 2011 19:39:38 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20110925193938.17248.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-25 19:39:38

Modified files:
	libdm          : libdm-config.c 

Log message:
	Chheck for failing filename strdup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/libdm/libdm-config.c	2011/09/25 19:38:59	1.7
+++ LVM2/libdm/libdm-config.c	2011/09/25 19:39:38	1.8
@@ -127,8 +127,13 @@
 	c->exists = 0;
 	c->keep_open = keep_open;
 	c->custom = NULL;
-	if (filename)
-		c->filename = dm_pool_strdup(c->mem, filename);
+	if (filename &&
+	    !(c->filename = dm_pool_strdup(c->mem, filename))) {
+		log_error("Failed to duplicate filename.");
+		dm_pool_destroy(mem);
+		return 0;
+	}
+
 	return &c->cft;
 }
 


