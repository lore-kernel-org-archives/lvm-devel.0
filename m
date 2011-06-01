From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Jun 2011 19:26:38 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20110601192638.25194.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-01 19:26:38

Modified files:
	lib/mm         : memlock.c 

Log message:
	Report sector containing label in verbose message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/lib/mm/memlock.c	2011/04/29 00:21:15	1.41
+++ LVM2/lib/mm/memlock.c	2011/06/01 19:26:38	1.42
@@ -374,6 +374,8 @@
 
 static void _lock_mem_if_needed(struct cmd_context *cmd)
 {
+	log_debug("Lock: Memlock counters: locked:%d critical:%d daemon:%d",
+		  _mem_locked, _critical_section_count, _memlock_count_daemon);
 	if (!_mem_locked &&
 	    ((_critical_section_count + _memlock_count_daemon) == 1)) {
 		_mem_locked = 1;
@@ -383,8 +385,8 @@
 
 static void _unlock_mem_if_possible(struct cmd_context *cmd)
 {
-	log_debug("UnlockMem l:%d cs:%d md:%d", _mem_locked,
-		  _critical_section_count, _memlock_count_daemon);
+	log_debug("Unlock: Memlock counters: locked:%d critical:%d daemon:%d",
+		  _mem_locked, _critical_section_count, _memlock_count_daemon);
 	if (_mem_locked &&
 	    !_critical_section_count &&
 	    !_memlock_count_daemon) {


