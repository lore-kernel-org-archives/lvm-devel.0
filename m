From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Sep 2011 19:45:41 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20110925194541.18853.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-25 19:45:40

Modified files:
	libdm          : libdm-config.c 

Log message:
	Remove test for NULL
	
	Since it's internal function and we always check for NULL value
	before call - this is safe.
	
	Just for case add nonnull attribute so analyzer might better
	catch error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/libdm/libdm-config.c	2011/09/25 19:43:43	1.12
+++ LVM2/libdm/libdm-config.c	2011/09/25 19:45:40	1.13
@@ -1225,14 +1225,12 @@
 		return 0;
 }
 
+__attribute__((nonnull(1, 2)))
 static struct dm_config_value *_clone_config_value(struct dm_pool *mem,
 						   const struct dm_config_value *v)
 {
 	struct dm_config_value *new_cv;
 
-	if (!v)
-		return NULL;
-
 	if (!(new_cv = _create_value(mem))) {
 		log_error("Failed to clone config value.");
 		return NULL;


