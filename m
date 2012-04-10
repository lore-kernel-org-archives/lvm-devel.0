From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 10 Apr 2012 12:55:38 -0000
Subject: LVM2/libdaemon client/daemon-client.c server/d ...
Message-ID: <20120410125538.11780.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-04-10 12:55:38

Modified files:
	libdaemon/client: daemon-client.c 
	libdaemon/server: daemon-server.c 

Log message:
	strcpy -> strncpy in common daemon code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-client.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/daemon-server.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/libdaemon/client/daemon-client.c	2012/03/01 21:12:40	1.3
+++ LVM2/libdaemon/client/daemon-client.c	2012/04/10 12:55:37	1.4
@@ -32,7 +32,7 @@
 		goto error;
 
 	memset(&sockaddr, 0, sizeof(sockaddr));
-	strcpy(sockaddr.sun_path, i.socket);
+	strncpy(sockaddr.sun_path, i.socket, sizeof(sockaddr.sun_path));
 	sockaddr.sun_family = AF_UNIX;
 	if (connect(h.socket_fd,(struct sockaddr *) &sockaddr, sizeof(sockaddr)))
 		goto error;
--- LVM2/libdaemon/server/daemon-server.c	2012/03/16 21:30:53	1.6
+++ LVM2/libdaemon/server/daemon-server.c	2012/04/10 12:55:38	1.7
@@ -224,7 +224,7 @@
 
 	fprintf(stderr, "[D] creating %s\n", s.socket_path);
 	memset(&sockaddr, 0, sizeof(sockaddr));
-	strcpy(sockaddr.sun_path, s.socket_path);
+	strncpy(sockaddr.sun_path, s.socket_path, sizeof(sockaddr.sun_path));
 	sockaddr.sun_family = AF_UNIX;
 
 	if (bind(fd, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {


