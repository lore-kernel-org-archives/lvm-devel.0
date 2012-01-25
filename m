From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 22:17:58 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c
Message-ID: <20120125221758.8270.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 22:17:57

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 

Log message:
	Test for uname result
	
	in fail path initialize to 0.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2243&r2=1.2244
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/WHATS_NEW	2012/01/25 22:16:04	1.2243
+++ LVM2/WHATS_NEW	2012/01/25 22:17:57	1.2244
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add missing check for uname result in clvmd TEST processing.
   Fix memleak in target_version() error path (unsupported LIST_VERSIONS).
   Limit alignment to 32bit values.
   Check for correctness of uint64 dev_size value.
--- LVM2/daemons/clvmd/clvmd-command.c	2011/12/08 18:32:33	1.62
+++ LVM2/daemons/clvmd/clvmd-command.c	2012/01/25 22:17:57	1.63
@@ -99,7 +99,9 @@
 			*buf = new_buf;
 		}
 		if (*buf) {
-			uname(&nodeinfo);
+			if (uname(&nodeinfo))
+				memset(&nodeinfo, 0, sizeof(nodeinfo));
+
 			*retlen = 1 + dm_snprintf(*buf, buflen,
 						  "TEST from %s: %s v%s",
 						  nodeinfo.nodename, args,


