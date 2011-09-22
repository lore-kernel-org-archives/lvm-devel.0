From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Sep 2011 09:45:25 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c
Message-ID: <20110922094525.13161.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-22 09:45:24

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 

Log message:
	Add all exclusive locks to clvmd restart option args
	
	Fix bug when only every even lock has been passed.
	
	Warning: currently -E causes clvmd to exit with usage text being printed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2127&r2=1.2128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2011/09/21 13:40:46	1.2127
+++ LVM2/WHATS_NEW	2011/09/22 09:45:24	1.2128
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add all exclusive locks to clvmd restart option args.
   Always send the whole clvmd packet header in refresh commands.
   Add missing error checks for some system calls in cmirrord.
   Add missing log_error() to lvresize command when fsadm tool fails.
--- LVM2/daemons/clvmd/clvmd-command.c	2011/06/03 09:05:30	1.56
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/09/22 09:45:24	1.57
@@ -369,7 +369,6 @@
 	DEBUGLOG("clvmd restart requested\n");
 
 	/* Count exclusively-open LVs */
-	hn = NULL;
 	do {
 		hn = get_next_excl_lock(hn, &lv_name);
 		if (lv_name)
@@ -403,6 +402,7 @@
 	 */
 
 	/* Now add the exclusively-open LVs */
+	hn = NULL;
 	do {
 		hn = get_next_excl_lock(hn, &lv_name);
 		if (lv_name) {
@@ -414,7 +414,6 @@
 				goto_out;
 
 			DEBUGLOG("excl lock: %s\n", lv_name);
-			hn = get_next_excl_lock(hn, &lv_name);
 		}
 	} while (hn && *lv_name);
 	argv[argc++] = NULL;


