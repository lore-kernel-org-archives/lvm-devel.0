From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 21 Jun 2010 10:45:18 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/refresh_clvmd.c
Message-ID: <20100621104518.21153.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-21 10:45:17

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : refresh_clvmd.c 

Log message:
	Let running clvmd process time to reexec.
	
	Because execve stops the command loop,
	we never receive response (only socket close) for clvmd -S,
	so waiting for response here makes no sense.
	
	But if the calling process (clvmd -S)  exits too early, connection
	is closed from client side, clvmd takes this as an error and
	never run restart code.
	
	Ugly hack(TM).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1620&r2=1.1621
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2010/06/21 08:54:32	1.1620
+++ LVM2/WHATS_NEW	2010/06/21 10:45:15	1.1621
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Add workaround for clvmd -S (socket closed too early and server drops the command).
   Use early udev synchronisation and update of dev nodes for clustered mirrors.
   Unneeded kdev_t.h reference causing harm for cmirrord on some archs.
   Add man pages for lvmconf and unsupported lvmsadc and lvmsar tools.
--- LVM2/daemons/clvmd/refresh_clvmd.c	2010/06/15 11:00:45	1.10
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2010/06/21 10:45:16	1.11
@@ -327,8 +327,21 @@
 
 int restart_clvmd(int all_nodes)
 {
-	int dummy;
-	return _cluster_request(CLVMD_CMD_RESTART, all_nodes?"*":".", NULL, 0, NULL, &dummy, 1);
+	int dummy, status;
+
+	status = _cluster_request(CLVMD_CMD_RESTART, all_nodes?"*":".", NULL, 0, NULL, &dummy, 1);
+
+	/*
+	 * FIXME: we cannot receive response, clvmd re-exec before it.
+	 *        but also should not close socket too early (the whole rq is dropped then).
+	 * FIXME: This should be handled this way:
+	 *  - client waits for RESTART ack (and socket close)
+	 *  - server restarts
+	 *  - client checks that server is ready again (VERSION command?)
+	 */
+	usleep(500000);
+
+	return status;
 }
 
 int debug_clvmd(int level, int clusterwide)


