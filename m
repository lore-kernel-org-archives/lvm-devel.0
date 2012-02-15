From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2012 13:56:48 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/libdevmap ...
Message-ID: <20120215135648.17591.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-15 13:56:47

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Detect failing fifo
	
	If the fifo died because of dmeventd restart - do not wait for 20s
	in select  - it will not get better and return error immediately.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.565&r2=1.566
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW_DM	2012/02/15 12:23:15	1.565
+++ LVM2/WHATS_NEW_DM	2012/02/15 13:56:47	1.566
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Detect failing fifo and skip 20s retry communication period.
   Add DM_DEFAULT_NAME_MANGLING_MODE env. variable to override configured value.
   Add dm_lib_init to automatically initialise device-mapper library on load.
   Replace any '\' char with '\\' in table specification on input.
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2012/02/13 11:24:09	1.44
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2012/02/15 13:56:47	1.45
@@ -232,6 +232,7 @@
 	size_t size = 2 * sizeof(uint32_t);	/* status + size */
 	uint32_t *header = alloca(size);
 	char *buf = (char *)header;
+	struct stat fstatbuf;
 
 	while (bytes < size) {
 		for (i = 0, ret = 0; (i < 20) && (ret < 1); i++) {
@@ -245,6 +246,13 @@
 				log_error("Unable to read from event server");
 				return 0;
 			}
+			/* Check whether fifo is still alive */
+			if ((ret == 0) &&
+			    fstat(fifos->server + 1, &fstatbuf) &&
+			    (errno == EBADF)) {
+				log_error("Fifo fd is bad for event server.");
+				return 0;
+			}
 		}
 		if (ret < 1) {
 			log_error("Unable to read from event server.");


