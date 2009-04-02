From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Apr 2009 15:02:19 -0000
Subject: LVM2/libdm/mm pool-debug.c
Message-ID: <20090402150219.10568.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-02 15:02:19

Modified files:
	libdm/mm       : pool-debug.c 

Log message:
	Fix debug pool grow object to properly support delta=0
	
	(It prints garbage for some reports)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-debug.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/libdm/mm/pool-debug.c	2009/03/26 09:25:18	1.6
+++ LVM2/libdm/mm/pool-debug.c	2009/04/02 15:02:18	1.7
@@ -218,14 +218,19 @@
 int dm_pool_grow_object(struct dm_pool *p, const void *extra, size_t delta)
 {
 	struct block *new;
-	size_t size = delta ? : strlen(extra);
+	size_t new_size;
+
+	if (!delta)
+		delta = strlen(extra);
 
 	assert(p->begun);
 
 	if (p->object)
-		size += p->object->size;
+		new_size = delta + p->object->size;
+	else
+		new_size = delta;
 
-	if (!(new = _new_block(size, DEFAULT_ALIGNMENT))) {
+	if (!(new = _new_block(new_size, DEFAULT_ALIGNMENT))) {
 		log_err("Couldn't extend object.");
 		return 0;
 	}
@@ -237,7 +242,7 @@
 	}
 	p->object = new;
 
-	memcpy(new->data + size - delta, extra, delta);
+	memcpy(new->data + new_size - delta, extra, delta);
 
 	return 1;
 }


