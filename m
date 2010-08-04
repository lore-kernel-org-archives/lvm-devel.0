From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 4 Aug 2010 18:18:18 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/functions.c
Message-ID: <20100804181818.18735.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-08-04 18:18:18

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: functions.c 

Log message:
	A misunderstanding of the return value of 'dm_bit' has been causing a data
	corruption bug in cmirror.  'dm_bit' is only ever used as a boolean operation
	within LVM, but it can return a range of values.  If the bit is set, a power of
	2 is returned.  If the bit is unset, 0 is returned.
	
	'log_test_bit' (a function in the cluster mirror log daemon code) has switched
	to using the dm bit operations in rhel6.  There are two places in the daemon
	code where 'log_test_bit' is not used merely as a boolean, but rather the
	return value is used as the return value for the log functions 'is_clean' and
	'in_sync' - having assumed that 'dm_bit' was returning 0 or 1 only.
	
	One place the 'in_sync' function is utilized is in 'dm_rh_get_state' - a
	function that informs the mirroring code how to treat I/O and which devices to
	read/write from.  'dm_rh_get_state' was checking if the return value of
	'in_sync' was 1 to determine if the region was DM_RH_CLEAN.  Since 'dm_bit'
	(and by extension 'log_test_bit' and 'in_sync') was returning powers of 2,
	DM_RH_CLEAN was rarely being reported as it should have been.  Thinking the
	region was out-of-sync, the mirroring code would write only to the primary
	device.  When the primary device was failed, all of those writes were lost -
	leaving the entire mirror corrupted.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1695&r2=1.1696
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2010/08/03 20:22:31	1.1695
+++ LVM2/WHATS_NEW	2010/08/04 18:18:18	1.1696
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix data corruption bug in cluster mirrors.
   Require logical volume(s) to be explicitly named for lvconvert --merge.
   Avoid changing aligned pe_start as a side-effect of very verbose logging.
   Fix 'void*' arithmetic warnings in dbg_malloc.c.
--- LVM2/daemons/cmirrord/functions.c	2010/07/09 15:34:41	1.21
+++ LVM2/daemons/cmirrord/functions.c	2010/08/04 18:18:18	1.22
@@ -106,7 +106,7 @@
 
 static int log_test_bit(dm_bitset_t bs, int bit)
 {
-	return dm_bit(bs, bit);
+	return dm_bit(bs, bit) ? 1 : 0;
 }
 
 static void log_set_bit(struct log_c *lc, dm_bitset_t bs, int bit)


