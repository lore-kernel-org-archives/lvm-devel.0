From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 11:03:25 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/libdevmapper ...
Message-ID: <20120228110325.570.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 11:03:24

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Better detection of missing dmeventd fifo connection

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2321&r2=1.2322
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/WHATS_NEW	2012/02/28 10:06:53	1.2321
+++ LVM2/WHATS_NEW	2012/02/28 11:03:24	1.2322
@@ -1,5 +1,7 @@
 Version 2.02.94 - 
 ====================================
+  Better detection of missing dmeventd fifo connection (2.02.93).
+  Add some close() and dev_close() error path backtraces.
   For polling daemon reopen stdin,stdout,stderr to /dev/null.
   Limit the max size of processed clvmd message to ~8KB.
   Do not send uninitilised bytes in cluster error reply messages.
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2012/02/28 10:14:06	1.46
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2012/02/28 11:03:24	1.47
@@ -232,7 +232,6 @@
 	size_t size = 2 * sizeof(uint32_t);	/* status + size */
 	uint32_t *header = alloca(size);
 	char *buf = (char *)header;
-	struct stat fstatbuf;
 
 	while (bytes < size) {
 		for (i = 0, ret = 0; (i < 20) && (ret < 1); i++) {
@@ -246,11 +245,8 @@
 				log_error("Unable to read from event server");
 				return 0;
 			}
-			/* Check whether fifo is still alive */
-			if ((ret == 0) &&
-			    fstat(fifos->server + 1, &fstatbuf) &&
-			    (errno == EBADF)) {
-				log_error("Fifo fd is bad for event server.");
+			if ((ret == 0) && i && !bytes) {
+				log_error("No input from event server.");
 				return 0;
 			}
 		}


