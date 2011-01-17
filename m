From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2011 19:02:45 -0000
Subject: LVM2/daemons/dmeventd dmeventd.h
Message-ID: <20110117190245.19132.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-17 19:02:45

Modified files:
	daemons/dmeventd: dmeventd.h 

Log message:
	remove unused definitions

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/daemons/dmeventd/dmeventd.h	2010/10/20 15:12:12	1.7
+++ LVM2/daemons/dmeventd/dmeventd.h	2011/01/17 19:02:44	1.8
@@ -17,11 +17,8 @@
 
 /* FIXME This stuff must be configurable. */
 
-#define	DM_EVENT_DAEMON		"/sbin/dmeventd"
-#define DM_EVENT_LOCKFILE	"/var/lock/dmeventd"
 #define	DM_EVENT_FIFO_CLIENT	"/var/run/dmeventd-client"
 #define	DM_EVENT_FIFO_SERVER	"/var/run/dmeventd-server"
-#define DM_EVENT_PIDFILE	"/var/run/dmeventd.pid"
 
 #define DM_EVENT_DEFAULT_TIMEOUT 10
 


