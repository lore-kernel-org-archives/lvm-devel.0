From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Oct 2008 12:25:56 -0000
Subject: LVM2 ./WHATS_NEW debian/README.Debian debian/c ...
Message-ID: <20081031122556.11631.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-31 12:25:54

Modified files:
	.              : WHATS_NEW 
Removed files:
	debian         : README.Debian changelog control copyright dirs 
	                 docs init.d manpages rules 

Log message:
	remove ancient debian dir

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.986&r2=1.987
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/debian/README.Debian.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/debian/changelog.diff?cvsroot=lvm2&r1=1.14&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/debian/control.diff?cvsroot=lvm2&r1=1.7&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/debian/copyright.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/debian/dirs.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/debian/docs.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/debian/init.d.diff?cvsroot=lvm2&r1=1.8&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/debian/manpages.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/debian/rules.diff?cvsroot=lvm2&r1=1.5&r2=NONE

--- LVM2/WHATS_NEW	2008/10/30 17:40:00	1.986
+++ LVM2/WHATS_NEW	2008/10/31 12:25:54	1.987
@@ -1,5 +1,6 @@
 Version 2.02.43 -
 ===================================
+  Remove ancient debian directory.
   Split out lvm-logging.h from log.h and lvm-globals.[ch] from log.[ch].
   Add libdm subdirectory for libdevmapper files.
 


