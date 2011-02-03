From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Feb 2011 16:03:14 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20110203160314.9476.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-03 16:03:13

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/format_text: import_vsn1.c 

Log message:
	Increase hash table size to 1024 lv names and 64 pv uuids

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1901&r2=1.1902
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/WHATS_NEW	2011/02/03 01:58:20	1.1901
+++ LVM2/WHATS_NEW	2011/02/03 16:03:13	1.1902
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Increase hash table size to 1024 lv names and 64 pv uuids.
   Remove fs_unlock() from lv_resume path.
   Fix wipe size when setting up mda.
   Remove unneeded checks for open_count in lv_info().
--- LVM2/daemons/clvmd/lvm-functions.c	2011/02/03 01:58:20	1.108
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/02/03 16:03:13	1.109
@@ -197,7 +197,7 @@
 void init_lvhash()
 {
 	/* Create hash table for keeping LV locks & status */
-	lv_hash = dm_hash_create(100);
+	lv_hash = dm_hash_create(1024);
 	pthread_mutex_init(&lv_hash_lock, NULL);
 	pthread_mutex_init(&lvm_lock, NULL);
 }
--- LVM2/lib/format_text/import_vsn1.c	2011/01/06 15:25:07	1.81
+++ LVM2/lib/format_text/import_vsn1.c	2011/02/03 16:03:13	1.82
@@ -756,7 +756,7 @@
 	 * The pv hash memorises the pv section names -> pv
 	 * structures.
 	 */
-	if (!(pv_hash = dm_hash_create(32))) {
+	if (!(pv_hash = dm_hash_create(64))) {
 		log_error("Couldn't create hash table.");
 		goto bad;
 	}
@@ -784,7 +784,7 @@
 	 * The lv hash memorises the lv section names -> lv
 	 * structures.
 	 */
-	if (!(lv_hash = dm_hash_create(32))) {
+	if (!(lv_hash = dm_hash_create(1024))) {
 		log_error("Couldn't create hash table.");
 		goto bad;
 	}


