From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 24 Apr 2007 15:13:15 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20070424151315.12276.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-04-24 16:13:14

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Fix thread race in clvmd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.599&r2=1.600
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2007/04/23 18:21:01	1.599
+++ LVM2/WHATS_NEW	2007/04/24 15:13:13	1.600
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Fix thread race in clvmd.
   Add scan_sector param to label_read and _find_labeller.
   Make clvmd cope with quorum devices on RHEL5
   Add dev_read_circular.
--- LVM2/daemons/clvmd/lvm-functions.c	2007/01/25 14:37:47	1.28
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/04/24 15:13:13	1.29
@@ -50,6 +50,7 @@
 static struct cmd_context *cmd = NULL;
 static struct dm_hash_table *lv_hash = NULL;
 static pthread_mutex_t lv_hash_lock;
+static pthread_mutex_t lvm_lock;
 static char last_error[1024];
 
 struct lv_info {
@@ -311,10 +312,12 @@
 	DEBUGLOG("do_lock_lv: resource '%s', cmd = 0x%x, flags = %x\n",
 		 resource, command, lock_flags);
 
+	pthread_mutex_lock(&lvm_lock);
 	if (!cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
 			log_error("Updated config file invalid. Aborting.");
+			pthread_mutex_unlock(&lvm_lock);
 			return EINVAL;
 		}
 	}
@@ -367,6 +370,7 @@
 
 	/* clean the pool for another command */
 	dm_pool_empty(cmd->mem);
+	pthread_mutex_unlock(&lvm_lock);
 
 	DEBUGLOG("Command return is %d\n", status);
 	return status;
@@ -393,6 +397,8 @@
 int post_lock_lv(unsigned char command, unsigned char lock_flags,
 		 char *resource)
 {
+	int status;
+
 	/* Opposite of above, done on resume after a metadata update */
 	if (command == LCK_LV_RESUME) {
 		int oldmode;
@@ -406,7 +412,10 @@
 		if (oldmode == LKM_PWMODE) {
 			struct lvinfo lvi;
 
-			if (!lv_info_by_lvid(cmd, resource, &lvi, 0))
+			pthread_mutex_lock(&lvm_lock);
+			status = lv_info_by_lvid(cmd, resource, &lvi, 0);
+			pthread_mutex_unlock(&lvm_lock);
+			if (!status)
 				return EIO;
 
 			if (lvi.exists) {
@@ -533,7 +542,7 @@
 			const char *message)
 {
 	/*
-	 * Ignore non-error messages, but store the latest one for returning 
+	 * Ignore non-error messages, but store the latest one for returning
 	 * to the user.
 	 */
 	if (level != _LOG_ERR && level != _LOG_FATAL)
@@ -572,6 +581,7 @@
 	/* Create hash table for keeping LV locks & status */
 	lv_hash = dm_hash_create(100);
 	pthread_mutex_init(&lv_hash_lock, NULL);
+	pthread_mutex_init(&lvm_lock, NULL);
 }
 
 /* Called to initialise the LVM context of the daemon */


