From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 May 2010 08:43:19 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20100511084319.5529.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-11 08:43:18

Modified files:
	.              : make.tmpl.in 

Log message:
	Skip unneeded 'cat' command execution.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/make.tmpl.in	2010/05/11 08:34:38	1.95
+++ LVM2/make.tmpl.in	2010/05/11 08:43:18	1.96
@@ -142,14 +142,11 @@
 
 LVM_VERSION := $(shell cat $(top_srcdir)/VERSION)
 
-LIB_VERSION_LVM := $(shell cat $(top_srcdir)/VERSION | \
-		     $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}')
+LIB_VERSION_LVM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)/VERSION)
 
-LIB_VERSION_DM := $(shell cat $(top_srcdir)/VERSION_DM | \
-		    $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}')
+LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)/VERSION_DM)
 
-LIB_VERSION_APP := $(shell cat $(top_srcdir)/VERSION | \
-		     $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}')
+LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_srcdir)/VERSION)
 
 INCLUDES += -I. -I$(top_builddir)/include
 


