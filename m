From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Feb 2010 18:16:10 -0000
Subject: LVM2/liblvm Makefile.in
Message-ID: <20100224181610.15791.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-24 18:16:10

Modified files:
	liblvm         : Makefile.in 

Log message:
	Add tag_list_copy() supporting function inside lvm2app.
	
	Add a supporting function to copy a list of internal tags to lvm2app list.
	We need to put this here because of the lvm_str_list_t type which we export
	in lvm2app.h.  If we didn't export this type, we could put this in the
	internal library and use struct str_list.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/liblvm/Makefile.in	2009/10/02 19:10:36	1.17
+++ LVM2/liblvm/Makefile.in	2010/02/24 18:16:10	1.18
@@ -18,6 +18,7 @@
 VPATH = @srcdir@
 
 SOURCES =\
+	lvm_misc.c \
 	lvm_base.c \
 	lvm_lv.c \
 	lvm_pv.c \


