From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 12 Aug 2010 09:15:01 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_red_hat.in
Message-ID: <20100812091501.3960.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2010-08-12 09:15:00

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_red_hat.in 

Log message:
	Fix clvmd init script return code when executed as non-root user.
	
	clvmd daemon itself does the right thing when invoked as non-root, by
	returning 4.
	
	The patch removes the use daemon function from
	/etc/rc.d/init.d/functions that??s unnecessary and has th bad habit to
	mask the return codes from the real daemon.
	
	Add a simple and generic check to see if clvmd is executed by root or not.
	
	Our stop/reload/restart paths in the init script are complex and not all
	the tools involved in the process are guaranteed to return 4 if executed
	by non-root against a process that??s running as root (for example kill
	-TERM will return -1 and parsing the output to catch the error is
	suboptimal at best).
	
	https://bugzilla.redhat.com/show_bug.cgi?id=553381

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1701&r2=1.1702
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2010/08/12 04:11:48	1.1701
+++ LVM2/WHATS_NEW	2010/08/12 09:14:59	1.1702
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix clvmd init script exit code when executed as non-root user.
   Change default alignment of pe_start to 1MB.
   Add --norestorefile option to pvcreate.
   Require --restorefile when using pvcreate --uuid.
--- LVM2/scripts/clvmd_init_red_hat.in	2010/06/23 16:24:14	1.9
+++ LVM2/scripts/clvmd_init_red_hat.in	2010/08/12 09:15:00	1.10
@@ -66,7 +66,7 @@
 {
 	if ! rh_status_q; then
 		echo -n "Starting $DAEMON: "
-		daemon $DAEMON $CLVMDOPTS || return $?
+		$DAEMON $CLVMDOPTS || return $?
 		echo
 	fi
 
@@ -165,6 +165,11 @@
 	fi
 }
 
+[ "$EUID" != "0" ] && {
+	echo "clvmd init script can only be executed as root user"
+	exit 4
+}
+
 # See how we were called.
 case "$1" in
   start)


