From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Mar 2011 17:00:58 -0000
Subject: LVM2 lib/metadata/metadata.c ./WHATS_NEW
Message-ID: <20110314170058.28997.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-14 17:00:58

Modified files:
	lib/metadata   : metadata.c 
	.              : WHATS_NEW 

Log message:
	Add missing \0 for grown debug object
	
	Attach \0 for proper char* display - otherwise somewhat random message could
	be displayed in debug more and read of unpredictable read of uninitilized
	memory values could happen.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.449&r2=1.450
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1955&r2=1.1956

--- LVM2/lib/metadata/metadata.c	2011/03/13 23:05:49	1.449
+++ LVM2/lib/metadata/metadata.c	2011/03/14 17:00:57	1.450
@@ -1066,6 +1066,12 @@
 		}
 	}
 
+	if (!dm_pool_grow_object(mem, "\0", 1)) {
+		log_error("Failed to finish list of random bits.");
+		dm_pool_free(mem, bs);
+		return NULL;
+	}
+
 	log_debug("Selected %" PRIu32 " random bits from %" PRIu32 ": %s", num_set_bits, num_bits, (char *) dm_pool_end_object(mem));
 
 	return bs;
--- LVM2/WHATS_NEW	2011/03/13 23:18:30	1.1955
+++ LVM2/WHATS_NEW	2011/03/14 17:00:58	1.1956
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Add missing \0 for grown debug object in _bitset_with_random_bits().
   Fix allocation of system_id buffer in volume_group structure.
   Fix readlink usage inside get_primary_dev().
   Use format instance mempool where possible and adequate.


