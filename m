From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jun 2010 12:49:31 -0000
Subject: LVM2 lib/config/defaults.h man/lvm.conf.5.in m ...
Message-ID: <20100630124931.31513.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-30 12:49:29

Modified files:
	lib/config     : defaults.h 
	man            : lvm.conf.5.in pvcreate.8.in 
	tools          : toollib.c 

Log message:
	Add pvmetadatacopies to lvm.conf and pvcreate man pages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.205&r2=1.206

--- LVM2/lib/config/defaults.h	2010/06/30 12:17:24	1.62
+++ LVM2/lib/config/defaults.h	2010/06/30 12:49:28	1.63
@@ -60,6 +60,7 @@
 
 #define DEFAULT_STRIPESIZE 64	/* KB */
 #define DEFAULT_PVMETADATAIGNORE 0
+#define DEFAULT_PVMETADATAIGNORE_STR "n"
 #define DEFAULT_PVMETADATASIZE 255
 #define DEFAULT_PVMETADATACOPIES 1
 #define DEFAULT_VGMETADATACOPIES 0
--- LVM2/man/lvm.conf.5.in	2010/06/28 20:38:23	1.9
+++ LVM2/man/lvm.conf.5.in	2010/06/30 12:49:29	1.10
@@ -406,6 +406,18 @@
 unused space becomes filled with an archive of the most recent
 previous versions of the metadata.
 .IP
+\fBpvmetadataignore\fP When creating a physical volume using the LVM2
+metadata format, this states whether metadata areas should be ignored.
+The default is "n".  If metadata areas on a physical volume are ignored,
+LVM will not not store metadata in the metadata areas present on newly
+created Physical Volumes.  The option can be overridden on the command
+line with \fB--pvmetadataignore\fP.  Metadata areas cannot be created
+or extended after Logical Volumes have been allocated on the device.
+If you do not want to store metadata on this device, it is still wise
+always to allocate a metadata area (use a non-zero value for
+\fB--pvmetadatacopies) in case you need it in the future and to use
+this option to instruct LVM2 to ignore it.
+.IP
 \fBvgmetadatacopies\fP \(em When creating a volume group using the
 LVM2 metadata format, this is the default number of copies of metadata
 desired across all the physical volumes in the volume group.  If set to
--- LVM2/man/pvcreate.8.in	2009/10/05 20:55:57	1.5
+++ LVM2/man/pvcreate.8.in	2010/06/30 12:49:29	1.6
@@ -13,6 +13,7 @@
 .RB [ \-M | \-\-metadatatype type ]
 .RB [ \-\-[pv]metadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
+.RB [ \-\-metadataignore y|n ]
 .RB [ \-\-dataalignment alignment ]
 .RB [ \-\-dataalignmentoffset alignment_offset ]
 .RB [ \-\-restorefile file ]
--- LVM2/tools/toollib.c	2010/06/30 12:17:25	1.205
+++ LVM2/tools/toollib.c	2010/06/30 12:49:29	1.206
@@ -1379,8 +1379,14 @@
 
 	if (arg_count(cmd, metadataignore_ARG)) {
 		pp->mda_ignore = !strcmp(arg_str_value(cmd,
-						       metadataignore_ARG,
-						       "n"), "y");
+						metadataignore_ARG,
+						DEFAULT_PVMETADATAIGNORE_STR),
+					 "y");
+	} else {
+		pp->mda_ignore = !strcmp(find_config_tree_str(cmd,
+					"metadata/pvmetadataignore",
+					DEFAULT_PVMETADATAIGNORE_STR),
+					"y");
 	}
 	if (arg_count(cmd, pvmetadatacopies_ARG) &&
 	    !arg_int_value(cmd, pvmetadatacopies_ARG, -1) &&


