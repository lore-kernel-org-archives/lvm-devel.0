From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 16 Mar 2012 21:30:54 -0000
Subject: LVM2/libdaemon/server daemon-server.c
Message-ID: <20120316213054.749.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-16 21:30:54

Modified files:
	libdaemon/server: daemon-server.c 

Log message:
	Do exit if LISTEN_PID environment variable not correct during systemd handover.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/daemon-server.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/libdaemon/server/daemon-server.c	2012/03/14 15:51:52	1.5
+++ LVM2/libdaemon/server/daemon-server.c	2012/03/16 21:30:53	1.6
@@ -177,7 +177,7 @@
 	env_pid = strtoul(e, &p, 10);
 	if (errno || !p || *p || env_pid <= 0 ||
 	    getpid() != (pid_t) env_pid)
-		;
+		goto out;
 
 	/* LISTEN_FDS must be 1 and the fd must be a socket! */
 	if (!(e = getenv(SD_LISTEN_FDS_ENV_VAR_NAME)))


