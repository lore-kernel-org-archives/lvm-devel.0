From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:59:52 -0000
Subject: LVM2/daemons/common daemon-shared.c
Message-ID: <20120119155952.2917.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:59:52

Modified files:
	daemons/common : daemon-shared.c 

Log message:
	Drop unused variable

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/daemons/common/daemon-shared.c	2012/01/16 05:09:16	1.8
+++ LVM2/daemons/common/daemon-shared.c	2012/01/19 15:59:51	1.9
@@ -18,7 +18,6 @@
 	int bytes = 0;
 	int buffersize = 32;
 	char *new;
-	char *end;
 	*buffer = malloc(buffersize + 1);
 
 	while (1) {


