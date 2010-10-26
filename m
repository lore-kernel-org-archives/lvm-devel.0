From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Oct 2010 09:57:04 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20101026095704.18295.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-26 09:57:03

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Hotfix usage of __builtin_unreachable()
	
	It's quite new feature which is not supported by older compilers.
	So until some better macros are introduced into LVM code - hotfix current
	compilation problems and compile this code only for __clang__ defining compilers.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/daemons/clvmd/clvmd.c	2010/10/26 09:01:47	1.79
+++ LVM2/daemons/clvmd/clvmd.c	2010/10/26 09:57:03	1.80
@@ -491,7 +491,9 @@
 		DEBUGLOG("Can't initialise cluster interface\n");
 		log_error("Can't initialise cluster interface\n");
 		child_init_signal(DFAIL_CLUSTER_IF);
+#ifdef __clang__
 		__builtin_unreachable();
+#endif
 	}
 	DEBUGLOG("Cluster ready, doing some more initialisation\n");
 
@@ -508,7 +510,9 @@
 	newfd = malloc(sizeof(struct local_client));
 	if (!newfd) {
 		child_init_signal(DFAIL_MALLOC);
+#ifdef __clang__
 		__builtin_unreachable();
+#endif
 	}
 
 	newfd->fd = local_sock;


