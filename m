From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Oct 2010 09:01:47 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20101026090147.12146.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-26 09:01:47

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Instrument compiler about code unreachability
	
	Clang needs some instrumentation help for static code analysis.
	It helps gcc and human reader as well.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/daemons/clvmd/clvmd.c	2010/10/20 14:46:45	1.78
+++ LVM2/daemons/clvmd/clvmd.c	2010/10/26 09:01:47	1.79
@@ -491,6 +491,7 @@
 		DEBUGLOG("Can't initialise cluster interface\n");
 		log_error("Can't initialise cluster interface\n");
 		child_init_signal(DFAIL_CLUSTER_IF);
+		__builtin_unreachable();
 	}
 	DEBUGLOG("Cluster ready, doing some more initialisation\n");
 
@@ -505,8 +506,10 @@
 
 	/* Add the local socket to the list */
 	newfd = malloc(sizeof(struct local_client));
-	if (!newfd)
-	        child_init_signal(DFAIL_MALLOC);
+	if (!newfd) {
+		child_init_signal(DFAIL_MALLOC);
+		__builtin_unreachable();
+	}
 
 	newfd->fd = local_sock;
 	newfd->removeme = 0;


