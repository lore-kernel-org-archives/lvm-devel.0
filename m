From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2010 12:44:48 -0000
Subject: LVM2 include/.symlinks.in lib/Makefile.in
Message-ID: <20100820124448.26335.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-08-20 12:44:48

Modified files:
	include        : .symlinks.in 
	lib            : Makefile.in 

Log message:
	Add properties.[ch] to lib/report, defined based on columns.h.
	
	Extend the existing reporting infrastructure definitions and structures
	to include a 'get' and 'set' function for each field.  We will provide
	a 'get' and 'set' function for each of these fields, which will be utilized
	by exported lvm2app functions.
	
	Define a default _not_implemented 'get' and 'set' function that just sets
	an errno and returns 0.  Future patches will actually implement the
	specific 'get' and 'set' functions for each property.  For read-only
	properties, only the 'get' function will be implemented.
	
	Define vg_get_property() function to query a property.  We will call
	this from a lvm2app function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/include/.symlinks.in	2010/01/21 22:15:46	1.2
+++ LVM2/include/.symlinks.in	2010/08/20 12:44:47	1.3
@@ -50,6 +50,7 @@
 @top_builddir@/lib/misc/lvm-version.h
 @top_srcdir@/lib/misc/lvm-wrappers.h
 @top_srcdir@/lib/misc/sharedlib.h
+ at top_srcdir@/lib/report/properties.h
 @top_srcdir@/lib/report/report.h
 @top_srcdir@/lib/uuid/uuid.h
 @top_srcdir@/libdm/libdevmapper.h
--- LVM2/lib/Makefile.in	2010/08/19 23:08:18	1.104
+++ LVM2/lib/Makefile.in	2010/08/20 12:44:47	1.105
@@ -90,6 +90,7 @@
 	misc/lvm-wrappers.c \
 	misc/util.c \
 	mm/memlock.c \
+	report/properties.c \
 	report/report.c \
 	striped/striped.c \
 	uuid/uuid.c \


