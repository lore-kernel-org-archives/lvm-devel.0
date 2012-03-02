From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 22:57:26 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM daemons/dmeven ...
Message-ID: <20120302225726.28039.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 22:57:25

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	daemons/dmeventd: dmeventd.c 

Log message:
	List _thread_registry missed mutex
	
	Operation on _thread_registry needs to be covered by mutex.
	Cosmetic move a die code after free for valgind short leak list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2334&r2=1.2335
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.582&r2=1.583
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/WHATS_NEW	2012/03/02 21:49:43	1.2334
+++ LVM2/WHATS_NEW	2012/03/02 22:57:25	1.2335
@@ -12,7 +12,6 @@
   Revert free of allocated segtype in init segment error path (2.02.89).
   Test dm_hash_insert() failures in filter-persistent.c and fid_add_mda().
   Ensure clvmd message is always \0 terminated after read.
-  Better detection of missing dmeventd fifo connection (2.02.93).
   Add some close() and dev_close() error path backtraces.
   For polling daemon reopen stdin,stdout,stderr to /dev/null.
   Limit the max size of processed clvmd message to ~8KB.
--- LVM2/WHATS_NEW_DM	2012/03/02 17:31:21	1.582
+++ LVM2/WHATS_NEW_DM	2012/03/02 22:57:25	1.583
@@ -1,8 +1,10 @@
 Version 1.02.73 - 
 ====================================
+  Test _thread_registry list with holding mutex in dmeventd.
   Added dm_tree_node_set_callback() for preload and deactivation hooks.
   Drop unsupported TRIM message for thin pool.
   Improve logging for fifo startup in dmeventd.
+  Better detection of missing dmeventd fifo connection (1.02.71).
   Add few pointer validation in dmsetup.
   Support dm_task_get_driver_version() query without version string.
   Log failure of pthread_join when cleaning unused threads in dmeventd.
--- LVM2/daemons/dmeventd/dmeventd.c	2012/03/01 22:54:17	1.94
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/03/02 22:57:25	1.95
@@ -1491,9 +1491,9 @@
 	if (!_client_write(fifos, &msg))
 		stack;
 
-	if (die) raise(9);
-
 	dm_free(msg.data);
+
+	if (die) raise(9);
 }
 
 static void _process_initial_registrations(void)
@@ -1987,11 +1987,13 @@
 	while (!_exit_now) {
 		_process_request(&fifos);
 		_cleanup_unused_threads();
+		_lock_mutex();
 		if (!dm_list_empty(&_thread_registry)
 		    || !dm_list_empty(&_thread_registry_unused))
 			_thread_registries_empty = 0;
 		else
 			_thread_registries_empty = 1;
+		_unlock_mutex();
 	}
 
 	_exit_dm_lib();


