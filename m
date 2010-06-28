From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:39:26 -0000
Subject: LVM2 man/vgsplit.8.in tools/commands.h tools/v ...
Message-ID: <20100628203926.20393.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:39:24

Modified files:
	man            : vgsplit.8.in 
	tools          : commands.h vgsplit.c 

Log message:
	Add --vgmetadatacopies to vgsplit man page and command.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/man/vgsplit.8.in	2009/09/02 21:27:22	1.2
+++ LVM2/man/vgsplit.8.in	2010/06/28 20:39:24	1.3
@@ -15,6 +15,8 @@
 .IR type ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
+.RB [ \-\-[vg]metadatacopies ]
+.IR NumberOfCopies|unmanaged|all ]
 .RB [ \-n | \-\-name 
 .IR LogicalVolumeName ]
 .RB [ \-t | \-\-test ]
@@ -36,9 +38,9 @@
 does not exist, a new volume group will be created.  The default attributes
 for the new volume group can be specified with \fB\-\-alloc\fR,
 \fB\-\-clustered\fR, \fB\-\-maxlogicalvolumes\fR, \fB\-\-metadatatype\fR,
-and \fB\-\-maxphysicalvolumes\fR (see \fBvgcreate(8)\fR for a description
-of these options).  If any of these options are not given, default
-attribute(s) are taken from
+\fB\-\-maxphysicalvolumes\fR and \fB\-\-[vg]metadatacopies\fR,
+(see \fBvgcreate(8)\fR for a description of these options).  If any
+of these options are not given, default attribute(s) are taken from
 .I SourceVolumeGroupName\fP.  If a non-LVM2 metadata type (e.g. lvm1) is
 being used, you should use the -M option to specify the metadata type
 directly.
@@ -58,6 +60,11 @@
 reason, \fBvgsplit(8)\fP may fail with an error if a split would result in a
 logical volume being split across volume groups.
 
+A \fBvgsplit\fP into an existing volume group retains the existing volume group's
+value of \fPvgmetadatacopies\fP (see \fBvgcreate\fP and \fBlvm.conf\fP for further
+explanation of \fPvgmetadatacopies\fP).  To change the value of
+\fBvgmetadatacopies\fP, use \fBvgchange\fP.
+
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH SEE ALSO
--- LVM2/tools/commands.h	2010/06/28 20:38:23	1.149
+++ LVM2/tools/commands.h	2010/06/28 20:39:24	1.150
@@ -1007,6 +1007,7 @@
    "\t[-h|--help] " "\n"
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
+   "\t[--[vg]metadatacopies #copies] " "\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
    "\t[-t|--test] " "\n"
@@ -1017,7 +1018,7 @@
 
    alloc_ARG, autobackup_ARG, clustered_ARG,
    maxlogicalvolumes_ARG, maxphysicalvolumes_ARG,
-   metadatatype_ARG, name_ARG, test_ARG)
+   metadatatype_ARG, vgmetadatacopies_ARG, name_ARG, test_ARG)
 
 xx(version,
    "Display software and driver version information",
--- LVM2/tools/vgsplit.c	2009/11/01 20:05:17	1.99
+++ LVM2/tools/vgsplit.c	2010/06/28 20:39:24	1.100
@@ -272,7 +272,8 @@
 	return(arg_count(cmd, clustered_ARG) ||
 	       arg_count(cmd, alloc_ARG) ||
 	       arg_count(cmd, maxphysicalvolumes_ARG) ||
-	       arg_count(cmd, maxlogicalvolumes_ARG));
+	       arg_count(cmd, maxlogicalvolumes_ARG) ||
+	       arg_count(cmd, vgmetadatacopies_ARG));
 }
 
 int vgsplit(struct cmd_context *cmd, int argc, char **argv)
@@ -382,7 +383,8 @@
 		    !vg_set_max_lv(vg_to, vp_new.max_lv) ||
 		    !vg_set_max_pv(vg_to, vp_new.max_pv) ||
 		    !vg_set_alloc_policy(vg_to, vp_new.alloc) ||
-		    !vg_set_clustered(vg_to, vp_new.clustered))
+		    !vg_set_clustered(vg_to, vp_new.clustered) ||
+		    !vg_set_mda_copies(vg_to, vp_new.metadata_copies))
 			goto_bad;
 	}
 


