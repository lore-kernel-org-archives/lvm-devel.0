From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jan 2012 10:33:42 -0000
Subject: LVM2/daemons/common daemon-server.c
Message-ID: <20120115103342.6707.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-01-15 10:33:41

Modified files:
	daemons/common : daemon-server.c 

Log message:
	Fix a couple of resource leaks in daemon-common server code -- filehandles and
	unjoined threads were leaked for each connection.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/daemons/common/daemon-server.c	2011/09/17 14:49:18	1.14
+++ LVM2/daemons/common/daemon-server.c	2012/01/15 10:33:41	1.15
@@ -251,9 +251,6 @@
 		if (!req.cft)
 			fprintf(stderr, "error parsing request:\n %s\n", req.buffer);
 		res = b->s.handler(b->s, b->client, req);
-		if (req.cft)
-			dm_config_destroy(req.cft);
-		dm_free(req.buffer);
 
 		if (!res.buffer) {
 			dm_config_write_node(res.cft->root, buffer_line, &res);
@@ -261,12 +258,17 @@
 			dm_config_destroy(res.cft);
 		}
 
+		if (req.cft)
+			dm_config_destroy(req.cft);
+		dm_free(req.buffer);
+
 		write_buffer(b->client.socket_fd, res.buffer, strlen(res.buffer));
 
 		free(res.buffer);
 	}
 fail:
 	/* TODO what should we really do here? */
+	close(b->client.socket_fd);
 	free(baton);
 	return NULL;
 }
@@ -291,6 +293,8 @@
 	if (pthread_create(&baton->client.thread_id, NULL, client_thread, baton))
 		return 0;
 
+	pthread_detach(baton->client.thread_id);
+
 	return 1;
 }
 


