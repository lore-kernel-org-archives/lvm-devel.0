From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 10:42:21 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20120228104221.23736.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 10:42:20

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Missed to properly merge patch for definition of MAX_MISSING_LEN
	
	(fix previous commit)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/daemons/clvmd/clvmd.c	2012/02/28 10:14:06	1.127
+++ LVM2/daemons/clvmd/clvmd.c	2012/02/28 10:42:20	1.128
@@ -49,7 +49,7 @@
 #endif
 
 #define MAX_RETRIES 4
-#define MAX_MISSING_LEN = 8000 /* Max supported clvmd message size ? */
+#define MAX_MISSING_LEN 8000 /* Max supported clvmd message size ? */
 
 #define ISLOCAL_CSID(c) (memcmp(c, our_csid, max_csid_len) == 0)
 


