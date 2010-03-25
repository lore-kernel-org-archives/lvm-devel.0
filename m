From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 18:16:55 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20100325181655.15550.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 18:16:55

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Add some assertions to allocation code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1479&r2=1.1480
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.214&r2=1.215

--- LVM2/WHATS_NEW	2010/03/25 11:48:54	1.1479
+++ LVM2/WHATS_NEW	2010/03/25 18:16:54	1.1480
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Add some assertions to allocation code.
   Introduce pv_area_used into allocation algorithm and add debug messages.
   Add activation/monitoring to lvm.conf.
   Add --monitor and --ignoremonitoring to lvcreate.
--- LVM2/lib/metadata/lv_manip.c	2010/03/25 02:40:09	1.214
+++ LVM2/lib/metadata/lv_manip.c	2010/03/25 18:16:55	1.215
@@ -600,6 +600,11 @@
 	if (segtype_is_virtual(segtype))
 		return ah;
 
+	if (!(area_count + log_area_count)) {
+		log_error(INTERNAL_ERROR "_alloc_init called for non-virtual segment with no disk space.");
+		return NULL;
+	}
+
 	if (!(ah->mem = dm_pool_create("allocation", 1024))) {
 		log_error("allocation pool creation failed");
 		return NULL;
@@ -744,6 +749,11 @@
 	uint32_t total_area_count = ah->area_count + (log_needs_allocating ? ah->log_area_count : 0);
 	struct alloced_area *aa;
 
+	if (!total_area_count) {
+		log_error(INTERNAL_ERROR "_alloc_parallel_area called without any allocation to do.");
+		return 1;
+	}
+
 	remaining = needed - *allocated;
 	area_len = remaining / ah->area_multiple;
 


