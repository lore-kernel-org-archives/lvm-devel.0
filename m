From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 Jan 2008 15:33:25 -0000
Subject: LVM2/dmeventd/snapshot .exported_symbols
Message-ID: <20080109153325.1786.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-01-09 15:33:25

Added files:
	dmeventd/snapshot: .exported_symbols 

Log message:
	Amend previous commit. * does not match .files...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/snapshot/.exported_symbols.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/dmeventd/snapshot/.exported_symbols,v  -->  standard output
revision 1.1
--- LVM2/dmeventd/snapshot/.exported_symbols
+++ -	2008-01-09 15:33:25.842041000 +0000
@@ -0,0 +1,3 @@
+process_event
+register_device
+unregister_device


