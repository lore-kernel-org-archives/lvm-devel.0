From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Aug 2011 12:13:52 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-singlenode.c
Message-ID: <20110804121352.21061.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-04 12:13:51

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-singlenode.c 

Log message:
	Add test for fcntl error in singlenode client code.
	
	Static analyzer noticed this check could be handy.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2048&r2=1.2049
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2011/08/04 10:14:42	1.2048
+++ LVM2/WHATS_NEW	2011/08/04 12:13:50	1.2049
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Add test for fcntl error in singlenode client code.
   Remove --force option from lvrename manpage.
   Add missing new line in lvrename help text.
   Add basic support for RAID 1/4/5/6 (i.e. create, remove, display)
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2011/03/24 10:45:00	1.10
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2011/08/04 12:13:51	1.11
@@ -55,7 +55,10 @@
 		goto error;
 	}
 	/* Set Close-on-exec */
-	fcntl(listen_fd, F_SETFD, 1);
+	if (fcntl(listen_fd, F_SETFD, 1)) {
+		DEBUGLOG("Setting CLOEXEC on client fd faile: %s\n", strerror(errno));
+		goto error;
+	}
 
 	memset(&addr, 0, sizeof(addr));
 	memcpy(addr.sun_path, SINGLENODE_CLVMD_SOCKNAME,


