From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 Aug 2011 12:57:11 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20110811125711.31107.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-08-11 12:57:11

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Never ever use uninitialised descriptors if pipe() fails
	(because of maximum open count fd exceeded or so).
	
	Better return busy message, so even clients fail in more controlled way.
	
	Without patch,  clvmd crashes with various strange backtraces
	if under heavy load of connection requests.
	
	https://bugzilla.redhat.com/show_bug.cgi?id=698393
	https://bugzilla.redhat.com/show_bug.cgi?id=697945
	
	(It still can OOM but that's different issue.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2061&r2=1.2062
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/WHATS_NEW	2011/08/11 05:00:20	1.2061
+++ LVM2/WHATS_NEW	2011/08/11 12:57:10	1.2062
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  If pipe in clvmd fails, return busy instead of using uninitialised descriptors.
   Add dmeventd monitoring shared library for RAID.
   Add RAID metadata devices to considered devices in _add_lv_to_dtree.
   Fix renaming of RAID logical volumes.
--- LVM2/daemons/clvmd/clvmd.c	2011/08/09 18:11:00	1.106
+++ LVM2/daemons/clvmd/clvmd.c	2011/08/11 12:57:11	1.107
@@ -1263,9 +1263,19 @@
 		}
 
 		/* Create a pipe and add the reading end to our FD list */
-		if (pipe(comms_pipe))
+		if (pipe(comms_pipe)) {
+			struct clvm_header reply;
 			DEBUGLOG("creating pipe failed: %s\n", strerror(errno));
-		
+			reply.cmd = CLVMD_CMD_REPLY;
+			reply.status = EBUSY;
+			reply.arglen = 0;
+			reply.flags = 0;
+			send_message(&reply, sizeof(reply), our_csid,
+				     thisfd->fd,
+				     "Error sending EBUSY reply to local user");
+			return len;
+		}
+
 		newfd = malloc(sizeof(struct local_client));
 		if (!newfd) {
 			struct clvm_header reply;


