From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Oct 2010 08:59:06 -0000
Subject: LVM2 libdm/mm/pool-fast.c ./WHATS_NEW
Message-ID: <20101026085906.11074.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-26 08:59:05

Modified files:
	libdm/mm       : pool-fast.c 
	.              : WHATS_NEW 

Log message:
	Use static indentifier for internal functions
	
	Functions _align_chunk() and  _new_chunk() are used only internally inside
	pool-fast.c - so keep them static inside this object file.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1778&r2=1.1779

--- LVM2/libdm/mm/pool-fast.c	2010/09/30 21:06:52	1.10
+++ LVM2/libdm/mm/pool-fast.c	2010/10/26 08:59:05	1.11
@@ -33,8 +33,8 @@
 	unsigned object_alignment;
 };
 
-void _align_chunk(struct chunk *c, unsigned alignment);
-struct chunk *_new_chunk(struct dm_pool *p, size_t s);
+static void _align_chunk(struct chunk *c, unsigned alignment);
+static struct chunk *_new_chunk(struct dm_pool *p, size_t s);
 static void _free_chunk(struct chunk *c);
 
 /* by default things come out aligned for doubles */
@@ -240,12 +240,12 @@
 	p->object_alignment = DEFAULT_ALIGNMENT;
 }
 
-void _align_chunk(struct chunk *c, unsigned alignment)
+static void _align_chunk(struct chunk *c, unsigned alignment)
 {
 	c->begin += alignment - ((unsigned long) c->begin & (alignment - 1));
 }
 
-struct chunk *_new_chunk(struct dm_pool *p, size_t s)
+static struct chunk *_new_chunk(struct dm_pool *p, size_t s)
 {
 	struct chunk *c;
 
--- LVM2/WHATS_NEW	2010/10/26 01:37:59	1.1778
+++ LVM2/WHATS_NEW	2010/10/26 08:59:05	1.1779
@@ -1,5 +1,6 @@
 Version 2.02.76
 ===================================
+  Use static for internal _align_chunk() and _new_chunk() from pool-fast.c.
   Fix vgchange to process -a, --refresh, --monitor and --poll like lvchange.
   Add lvm2app functions to query any pv, vg, or lv property / report field.
 


