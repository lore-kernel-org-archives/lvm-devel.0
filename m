From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Jul 2009 20:29:57 -0000
Subject: LVM2/liblvm Makefile.in
Message-ID: <20090722202957.32215.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-22 20:29:57

Modified files:
	liblvm         : Makefile.in 

Log message:
	fix dir in generated file list for cflow

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/liblvm/Makefile.in	2009/07/22 20:12:14	1.8
+++ LVM2/liblvm/Makefile.in	2009/07/22 20:29:56	1.9
@@ -42,7 +42,7 @@
 liblvm.cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \
 		 echo $(SOURCES) | \
-		 sed "s/^/ /;s/ / $(top_srcdir)\/lib\//g;s/$$//"; \
+		 sed "s/^/ /;s/ / $(top_srcdir)\/liblvm\//g;s/$$//"; \
 		 ) > $@
 
 cflow: liblvm.cflow


