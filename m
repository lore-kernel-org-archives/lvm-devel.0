From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Jun 2011 12:27:34 -0000
Subject: LVM2/daemons/lvmetad testclient.c
Message-ID: <20110627122734.2906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-27 12:27:34

Modified files:
	daemons/lvmetad: testclient.c 

Log message:
	Call daemon_close before exit in the testclient.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/testclient.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/lvmetad/testclient.c	2011/06/14 02:36:38	1.1
+++ LVM2/daemons/lvmetad/testclient.c	2011/06/27 12:27:34	1.2
@@ -8,5 +8,6 @@
 		daemon_reply reply = daemon_send(h, rq);
 		fprintf(stderr, "daemon says: %s\n", reply.buffer);
 	}
+	daemon_close(h);
 	return 0;
 }


