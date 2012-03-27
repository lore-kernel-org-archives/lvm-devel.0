From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Mar 2012 13:39:09 -0000
Subject: LVM2/doc tagging.txt
Message-ID: <20120327133909.20317.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-27 13:39:08

Modified files:
	doc            : tagging.txt 

Log message:
	There is no hotsname_tags but only hosttags... sigh, even docs is wrong :-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/tagging.txt.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/doc/tagging.txt	2011/11/22 13:54:05	1.2
+++ LVM2/doc/tagging.txt	2012/03/27 13:39:08	1.3
@@ -79,7 +79,7 @@
 
   lvm.conf:  (Identical on every machine - global settings)
     tags {
-      hostname_tags = 1
+      hosttags = 1
     }
 
   From any machine in the cluster, add db1 to the list of machines that


