From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Oct 2009 11:35:26 -0000
Subject: LVM2 Makefile.in
Message-ID: <20091002113526.3084.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-10-02 11:35:26

Modified files:
	.              : Makefile.in 

Log message:
	Remove daemons/clogd from distclean dirs (replaced with cmirrord)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/Makefile.in	2009/10/02 09:47:11	1.40
+++ LVM2/Makefile.in	2009/10/02 11:35:25	1.41
@@ -34,7 +34,6 @@
 
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS += daemons/clvmd \
-	     daemons/clogd \
 	     daemons/cmirrord \
 	     daemons/dmeventd/plugins \
 	     daemons/dmeventd \


