From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 11:23:14 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20101129112314.17136.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 11:23:14

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Remove dead assignment in 'main'
	
	'ret' is never read anywhere - remove it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/daemons/dmeventd/dmeventd.c	2010/10/26 08:54:37	1.69
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/11/29 11:23:14	1.70
@@ -1761,7 +1761,6 @@
 
 int main(int argc, char *argv[])
 {
-	int ret;
 	signed char opt;
 	struct dm_event_fifos fifos;
 	//struct sys_log logdata = {DAEMON_NAME, LOG_DAEMON};
@@ -1835,7 +1834,7 @@
 
 	pthread_mutex_init(&_global_mutex, NULL);
 
-	if ((ret = _open_fifos(&fifos)))
+	if (_open_fifos(&fifos))
 		exit(EXIT_FIFO_FAILURE);
 
 	/* Signal parent, letting them know we are ready to go. */


