From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:42:08 -0000
Subject: LVM2/daemons/dmeventd/plugins/thin .exported_s ...
Message-ID: <20111221134208.10750.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:42:07

Added files:
	daemons/dmeventd/plugins/thin: .exported_symbols 

Log message:
	Exported functions from thin plugin

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/thin/.exported_symbols.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/daemons/dmeventd/plugins/thin/.exported_symbols,v  -->  standard output
revision 1.1
--- LVM2/daemons/dmeventd/plugins/thin/.exported_symbols
+++ -	2011-12-21 13:42:08.035594000 +0000
@@ -0,0 +1,3 @@
+process_event
+register_device
+unregister_device


