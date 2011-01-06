From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Jan 2011 09:45:06 -0000
Subject: LVM2/daemons/dmeventd libdevmapper-event.c
Message-ID: <20110106094506.14126.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-06 09:45:05

Modified files:
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Remove unneeded stack prints after log_error

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/daemons/dmeventd/libdevmapper-event.c	2010/12/22 15:28:44	1.37
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2011/01/06 09:45:05	1.38
@@ -432,7 +432,6 @@
 
 		log_error("%s: Can't open client fifo %s: %s",
 			  __func__, fifos->client_path, strerror(errno));
-		stack;
 		return 0;
 	}
 
@@ -441,7 +440,7 @@
 
 	if (!strncmp(DMEVENTD_PATH, "/", 1) && stat(DMEVENTD_PATH, &statbuf)) {
 		log_error("Unable to find dmeventd.");
-		return_0;
+		return 0;
 	}
 
 	pid = fork();
@@ -479,7 +478,6 @@
 	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
 		log_error("%s: open server fifo %s",
 			  __func__, fifos->server_path);
-		stack;
 		return 0;
 	}
 
@@ -495,7 +493,6 @@
 		log_error("%s: Can't open client fifo %s: %s",
 			  __func__, fifos->client_path, strerror(errno));
 		close(fifos->server);
-		stack;
 		return 0;
 	}
 


