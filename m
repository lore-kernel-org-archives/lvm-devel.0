From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Mar 2011 14:20:49 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20110302142049.18436.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-03-02 14:20:48

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Do not run past the end of an array in dmeventd's _handle_request when faced
	with an unknown command ID.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/daemons/dmeventd/dmeventd.c	2011/03/02 12:49:13	1.76
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/03/02 14:20:48	1.77
@@ -1388,7 +1388,7 @@
 static int _handle_request(struct dm_event_daemon_message *msg,
 			  struct message_data *message_data)
 {
-	static struct {
+	static struct request {
 		unsigned int cmd;
 		int (*f)(struct message_data *);
 	} requests[] = {
@@ -1403,7 +1403,7 @@
 		{ DM_EVENT_CMD_GET_STATUS, _get_status},
 	}, *req;
 
-	for (req = requests; req < requests + sizeof(requests); req++)
+	for (req = requests; req < requests + sizeof(requests) / sizeof(struct request); req++)
 		if (req->cmd == msg->cmd)
 			return req->f(message_data);
 


