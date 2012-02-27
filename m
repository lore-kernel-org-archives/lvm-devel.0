From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:49:17 -0000
Subject: LVM2/daemons/common daemon-client.c
Message-ID: <20120227114917.32509.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:49:16

Modified files:
	daemons/common : daemon-client.c 

Log message:
	Do not hide deallocation of buffer
	
	As API is passing structures by value, do not leave
	the function which created buffer and keeps valid pointer
	look like it would be some memory leak and move
	free of buffer from inner function - makes more obvious,
	how is the memory management handled.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/daemons/common/daemon-client.c	2012/02/26 08:46:28	1.15
+++ LVM2/daemons/common/daemon-client.c	2012/02/27 11:49:16	1.16
@@ -62,8 +62,6 @@
 	if (!write_buffer(h.socket_fd, rq.buffer, strlen(rq.buffer)))
 		reply.error = errno;
 
-	dm_free(rq.buffer);
-
 	if (read_buffer(h.socket_fd, &reply.buffer)) {
 		reply.cft = dm_config_from_string(reply.buffer);
 	} else
@@ -93,6 +91,8 @@
 		return err;
 
 	repl = daemon_send(h, rq);
+	dm_free(rq.buffer);
+
 	return repl;
 }
 


