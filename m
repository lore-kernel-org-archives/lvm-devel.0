From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 09:56:57 -0000
Subject: LVM2/libdm Makefile.in
Message-ID: <20100304095657.24615.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 09:56:56

Modified files:
	libdm          : Makefile.in 

Log message:
	This patch moves inclusion of the make.tmpl before DEFS modification,
	so it goes in the same order on the compilation line.
	(i.e. HAVE_CONFIG_H goes first)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/libdm/Makefile.in	2010/03/04 09:51:40	1.47
+++ LVM2/libdm/Makefile.in	2010/03/04 09:56:56	1.48
@@ -47,11 +47,11 @@
 VERSIONED_SHLIB = libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
 LIB_VERSION = $(LIB_VERSION_DM)
 
+include $(top_builddir)/make.tmpl
+
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
-include $(top_builddir)/make.tmpl
-
 device-mapper: all
 
 .PHONY: install_dynamic install_static install_include \


