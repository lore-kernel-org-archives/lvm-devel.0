From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 8 Mar 2012 14:54:05 -0000
Subject: LVM2/libdaemon/server daemon-server.c
Message-ID: <20120308145405.5620.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-08 14:54:05

Modified files:
	libdaemon/server: daemon-server.c 

Log message:
	Do not unlink the socket on daemon shutdown if activation is done via systemd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/daemon-server.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/libdaemon/server/daemon-server.c	2012/03/01 21:12:40	1.3
+++ LVM2/libdaemon/server/daemon-server.c	2012/03/08 14:54:05	1.4
@@ -508,7 +508,8 @@
 				syslog(LOG_ERR, "Failed to handle a client connection.");
 	}
 
-	if (s.socket_fd >= 0)
+	/* If activated by systemd, do not unlink the socket - systemd takes care of that! */
+	if (!_systemd_activation && s.socket_fd >= 0)
 		if (unlink(s.socket_path))
 			perror("unlink error");
 


