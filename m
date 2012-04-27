From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 27 Apr 2012 09:52:34 -0000
Subject: LVM2/libdaemon client/daemon-client.c server/d ...
Message-ID: <20120427095234.5648.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-04-27 09:52:33

Modified files:
	libdaemon/client: daemon-client.c 
	libdaemon/server: daemon-server.c 

Log message:
	Use dm_strncpy instead of plain strncpy while setting the socket path.
	
	Also check the return value as it meaningless to work with truncated strings.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-client.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/daemon-server.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/libdaemon/client/daemon-client.c	2012/04/10 12:55:37	1.4
+++ LVM2/libdaemon/client/daemon-client.c	2012/04/27 09:52:33	1.5
@@ -32,7 +32,10 @@
 		goto error;
 
 	memset(&sockaddr, 0, sizeof(sockaddr));
-	strncpy(sockaddr.sun_path, i.socket, sizeof(sockaddr.sun_path));
+	if (!dm_strncpy(sockaddr.sun_path, i.socket, sizeof(sockaddr.sun_path))) {
+		fprintf(stderr, "%s: daemon socket path too long.\n", i.socket);
+		goto error;
+	}
 	sockaddr.sun_family = AF_UNIX;
 	if (connect(h.socket_fd,(struct sockaddr *) &sockaddr, sizeof(sockaddr)))
 		goto error;
--- LVM2/libdaemon/server/daemon-server.c	2012/04/10 12:55:38	1.7
+++ LVM2/libdaemon/server/daemon-server.c	2012/04/27 09:52:33	1.8
@@ -224,7 +224,10 @@
 
 	fprintf(stderr, "[D] creating %s\n", s.socket_path);
 	memset(&sockaddr, 0, sizeof(sockaddr));
-	strncpy(sockaddr.sun_path, s.socket_path, sizeof(sockaddr.sun_path));
+	if (!dm_strncpy(sockaddr.sun_path, s.socket_path, sizeof(sockaddr.sun_path))) {
+		fprintf(stderr, "%s: daemon socket path too long.\n", s.socket_path);
+		goto error;
+	}
 	sockaddr.sun_family = AF_UNIX;
 
 	if (bind(fd, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {


