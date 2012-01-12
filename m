From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jan 2012 18:29:11 -0000
Subject: LVM2 ./WHATS_NEW lib/mm/memlock.c
Message-ID: <20120112182911.10128.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-12 18:29:08

Modified files:
	.              : WHATS_NEW 
	lib/mm         : memlock.c 

Log message:
	Make error message hit when preallocated memlock memory exceeded clearer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2221&r2=1.2222
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2012/01/12 16:58:43	1.2221
+++ LVM2/WHATS_NEW	2012/01/12 18:29:07	1.2222
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Make error message hit when preallocated memlock memory exceeded clearer.
   Use R lv_attr to indicate read-only activation of non-read-only device in lvs.
   Show read-only activation override in lvdisplay & add 4 to perms in -c.
   Add activation/read_only_volume_list to override LV permission in metadata.
--- LVM2/lib/mm/memlock.c	2011/12/08 21:24:09	1.47
+++ LVM2/lib/mm/memlock.c	2012/01/12 18:29:08	1.48
@@ -147,7 +147,7 @@
  * format described in kernel/Documentation/filesystem/proc.txt
  */
 static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
-		      const char* line, size_t* mstats)
+		      const char *line, size_t *mstats)
 {
 	const struct dm_config_value *cv;
 	long from, to;
@@ -357,7 +357,7 @@
 		if (_mstats < unlock_mstats) {
 			if ((_mstats + lvm_getpagesize()) < unlock_mstats)
 				log_error(INTERNAL_ERROR
-					  "Maps lock %ld < unlock %ld",
+					  "Reserved memory (%ld) not enough: used %ld. Increase activation/reserved_memory?",
 					  (long)_mstats, (long)unlock_mstats);
 			else
 				/* FIXME Believed due to incorrect use of yes_no_prompt while locks held */


