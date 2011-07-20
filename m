From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 18:23:34 -0000
Subject: LVM2/daemons/common daemon-server.c
Message-ID: <20110720182334.13095.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 18:23:34

Modified files:
	daemons/common : daemon-server.c 

Log message:
	Fix two small (but eventually unbounded) leaks in daemon-server.c.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/daemons/common/daemon-server.c	2011/07/18 14:46:54	1.8
+++ LVM2/daemons/common/daemon-server.c	2011/07/20 18:23:33	1.9
@@ -253,6 +253,7 @@
 		if (!res.buffer) {
 			write_config_node(res.cft->root, buffer_line, &res);
 			buffer_rewrite(&res.buffer, "%s\n\n", NULL);
+			destroy_config_tree(res.cft);
 		}
 
 		write_buffer(b->client.socket_fd, res.buffer, strlen(res.buffer));
@@ -261,6 +262,7 @@
 	}
 fail:
 	/* TODO what should we really do here? */
+	free(baton);
 	return NULL;
 }
 


