From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 12:16:16 -0000
Subject: LVM2/libdm/mm pool-debug.c
Message-ID: <20110330121616.24083.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 12:16:16

Modified files:
	libdm/mm       : pool-debug.c 

Log message:
	Simplify pool debug initialization
	
	zalloc pool structure and skip zeroing members.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-debug.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/libdm/mm/pool-debug.c	2011/02/28 19:54:30	1.10
+++ LVM2/libdm/mm/pool-debug.c	2011/03/30 12:16:15	1.11
@@ -48,7 +48,7 @@
 
 struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 {
-	struct dm_pool *mem = dm_malloc(sizeof(*mem));
+	struct dm_pool *mem = dm_zalloc(sizeof(*mem));
 
 	if (!mem) {
 		log_error("Couldn't create memory pool %s (size %"
@@ -57,16 +57,6 @@
 	}
 
 	mem->name = name;
-	mem->begun = 0;
-	mem->object = 0;
-	mem->blocks = mem->tail = NULL;
-
-	mem->stats.block_serialno = 0;
-	mem->stats.blocks_allocated = 0;
-	mem->stats.blocks_max = 0;
-	mem->stats.bytes = 0;
-	mem->stats.maxbytes = 0;
-
 	mem->orig_pool = mem;
 
 #ifdef DEBUG_POOL


