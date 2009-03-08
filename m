From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Mar 2009 18:58:53 -0000
Subject: LVM2/liblvm .exported_symbols
Message-ID: <20090308185853.21904.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-08 18:58:53

Added files:
	liblvm         : .exported_symbols 

Log message:
	Add missing liblvm/.exported_symbols

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/liblvm/.exported_symbols,v  -->  standard output
revision 1.1
--- LVM2/liblvm/.exported_symbols
+++ -	2009-03-08 18:58:53.679071000 +0000
@@ -0,0 +1,3 @@
+lvm_create
+lvm_destroy
+lvm_reload_config
\ No newline at end of file


