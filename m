From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2010 14:40:30 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20100330144030.19212.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-30 14:40:30

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Force C locale
	
	As we need to use mlockall() enforce "C" locales for dmeventd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/daemons/dmeventd/dmeventd.c	2010/03/30 14:37:28	1.56
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/03/30 14:40:30	1.57
@@ -1698,6 +1698,13 @@
 		}
 	}
 
+	/*
+	 * Switch to C locale to avoid reading large locale-archive file
+	 * used by some glibc (on some distributions it takes over 100MB).
+	 * Daemon currently needs to use mlockall().
+	 */
+	setenv("LANG", "C", 1);
+
 	if (!_debug)
 		_daemonize();
 


