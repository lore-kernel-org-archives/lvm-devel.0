From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Sep 2011 17:05:44 -0000
Subject: LVM2/man Makefile.in
Message-ID: <20110923170544.16915.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-23 17:05:44

Modified files:
	man            : Makefile.in 

Log message:
	missing Makefile dep

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/man/Makefile.in	2011/09/23 09:48:21	1.41
+++ LVM2/man/Makefile.in	2011/09/23 17:05:44	1.42
@@ -68,7 +68,7 @@
 
 man: $(MAN5) $(MAN8) $(MAN8CLUSTER)
 
-$(MAN5) $(MAN8) $(MAN8CLUSTER):	Makefile
+$(MAN5) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 
 %: %.in
 	@case "$@" in \


