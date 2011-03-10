From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Mar 2011 14:49:02 -0000
Subject: LVM2/libdm/mm pool-fast.c pool.c
Message-ID: <20110310144902.23907.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-10 14:49:01

Modified files:
	libdm/mm       : pool-fast.c pool.c 

Log message:
	Keep pool name also for pool-fast
	
	It's cheap to keep this name - and it is useful for 'non pool debug code'
	compilation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/libdm/mm/pool-fast.c	2010/10/26 08:59:05	1.11
+++ LVM2/libdm/mm/pool-fast.c	2011/03/10 14:49:01	1.12
@@ -28,6 +28,7 @@
 	struct dm_list list;
 	struct chunk *chunk, *spare_chunk;	/* spare_chunk is a one entry free
 						   list to stop 'bobbling' */
+	const char *name;
 	size_t chunk_size;
 	size_t object_len;
 	unsigned object_alignment;
@@ -51,6 +52,7 @@
 		return 0;
 	}
 
+	p->name = name;
 	/* round chunk_hint up to the next power of 2 */
 	p->chunk_size = chunk_hint + sizeof(struct chunk);
 	while (new_size < p->chunk_size)
--- LVM2/libdm/mm/pool.c	2009/04/10 09:56:59	1.5
+++ LVM2/libdm/mm/pool.c	2011/03/10 14:49:01	1.6
@@ -71,7 +71,7 @@
 			  p->orig_pool,
 			  p->name, p->stats.bytes);
 #else
-		log_error(" [%p]", p);
+		log_error(" [%p] %s", p, p->name);
 #endif
 	}
 }


