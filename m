From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Sep 2011 09:53:32 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20110914095332.1425.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-14 09:53:32

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Keep the old-style function definition

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/daemons/dmeventd/dmeventd.c	2011/08/31 08:23:05	1.83
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/09/14 09:53:32	1.84
@@ -1632,7 +1632,7 @@
 /*
  * Protection against OOM killer if kernel supports it
  */
-static int _protect_against_oom_killer()
+static int _protect_against_oom_killer(void)
 {
 	struct stat st;
 


