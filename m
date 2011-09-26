From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Sep 2011 07:51:26 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20110926075126.9130.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-26 07:51:25

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 
	test           : t-clvmd-restart.sh 

Log message:
	Use execvp for clvmd restart
	
	Since execve passed only NULL as environ, we had lost all environment vars on
	restart - thus actually running  'different' clvmd then the one at start.
	
	Preserving environ allows to restart clvmd with the same settings
	(i.e. LD_LIBRARY_PATH)
	
	Add test for second restart.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2139&r2=1.2140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-clvmd-restart.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2011/09/25 19:37:00	1.2139
+++ LVM2/WHATS_NEW	2011/09/26 07:51:23	1.2140
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Use execvp for CLVMD restart to preserve environment settings.
   Restart CLVMD with same cluster manager.
   Fix log_error() usage in raid and unknown segtype initialisation.
   Improve testing Makefile.
--- LVM2/daemons/clvmd/clvmd-command.c	2011/09/25 19:37:00	1.60
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/09/26 07:51:24	1.61
@@ -418,7 +418,7 @@
 	for (argc = 1; argv[argc]; argc++) DEBUGLOG("--- %d: %s\n", argc, argv[argc]);
 
 	/* NOTE: This will fail when downgrading! */
-	execve(clvmd, (char **)argv, NULL);
+	execvp(clvmd, (char **)argv);
 out:
 	/* We failed */
 	DEBUGLOG("Restart of clvmd failed.\n");
--- LVM2/test/t-clvmd-restart.sh	2011/09/25 19:37:00	1.1
+++ LVM2/test/t-clvmd-restart.sh	2011/09/26 07:51:24	1.2
@@ -9,13 +9,15 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-export LVM_CLVMD_BINARY="lib/clvmd"
-export LVM_BINARY="lib/lvm"
+# set before test's clvmd is started, so it's passed in environ
+export LVM_CLVMD_BINARY=clvmd
+export LVM_BINARY=lvm
 
 . lib/test
 
 # only clvmd based test, skip otherwise
 test -e LOCAL_CLVMD || skip
+read LOCAL_CLVMD < LOCAL_CLVMD
 
 aux prepare_devs 1
 
@@ -30,15 +32,22 @@
 
 "$LVM_CLVMD_BINARY" -S
 sleep .2
-# restarted clvmd has the same PID (no fork, only execve)
+# restarted clvmd has the same PID (no fork, only execvp)
+NEW_LOCAL_CLVMD=$(pgrep clvmd)
+test "$LOCAL_CLVMD" -eq "$NEW_LOCAL_CLVMD"
+
+# try restart once more
+
+"$LVM_CLVMD_BINARY" -S
+sleep .2
+# restarted clvmd has the same PID (no fork, only execvp)
 NEW_LOCAL_CLVMD=$(pgrep clvmd)
-read LOCAL_CLVMD < LOCAL_CLVMD
 test "$LOCAL_CLVMD" -eq "$NEW_LOCAL_CLVMD"
 
 # FIXME: Hmm - how could we test exclusivity is preserved in singlenode ?
 lvchange -an $vg/$lv1
 lvchange -ay $vg/$lv1
 
-lib/clvmd -R
+"$LVM_CLVMD_BINARY" -R
 
 vgremove -ff $vg


