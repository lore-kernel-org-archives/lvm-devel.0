From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Sep 2011 08:57:23 -0000
Subject: LVM2/daemons/clvmd clvmd-singlenode.c
Message-ID: <20110929085723.16221.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-29 08:57:22

Modified files:
	daemons/clvmd  : clvmd-singlenode.c 

Log message:
	Typo in debug message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/daemons/clvmd/clvmd-singlenode.c	2011/09/25 19:37:00	1.12
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2011/09/29 08:57:21	1.13
@@ -56,7 +56,7 @@
 	}
 	/* Set Close-on-exec */
 	if (fcntl(listen_fd, F_SETFD, 1)) {
-		DEBUGLOG("Setting CLOEXEC on client fd faile: %s\n", strerror(errno));
+		DEBUGLOG("Setting CLOEXEC on client fd failed: %s\n", strerror(errno));
 		goto error;
 	}
 


