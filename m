From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Mar 2012 09:43:44 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20120323094344.20231.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-23 09:43:44

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Make sure namelen fits into buffer allocated on stack

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/daemons/clvmd/clvmd.c	2012/03/01 21:14:43	1.131
+++ LVM2/daemons/clvmd/clvmd.c	2012/03/23 09:43:44	1.132
@@ -2323,6 +2323,9 @@
         if (result != CS_OK)
 		goto out;
 
+	if (namelen >= sizeof(buf))
+		namelen = sizeof(buf) - 1;
+
 	buf[namelen] = '\0';
 	type = parse_cluster_interface(buf);
 	DEBUGLOG("got interface type '%s' from confdb\n", buf);


