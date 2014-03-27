From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 27 Mar 2014 13:18:53 +0000 (UTC)
Subject: master - man: better formatting for lvm dumpconfig man page
Message-ID: <20140327131853.9AB8A60DEF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d314466f338a365d00092edea8e62066ef87dc2
Commit:        6d314466f338a365d00092edea8e62066ef87dc2
Parent:        801d43445dee66a95f15f447a9384cd3f3037199
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 27 14:18:41 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 27 14:18:41 2014 +0100

man: better formatting for lvm dumpconfig man page

---
 man/lvm-dumpconfig.8.in |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/man/lvm-dumpconfig.8.in b/man/lvm-dumpconfig.8.in
index 0240639..7448992 100644
--- a/man/lvm-dumpconfig.8.in
+++ b/man/lvm-dumpconfig.8.in
@@ -3,10 +3,10 @@
 lvm-dumpconfig \- dump LVM configuration
 .SH SYNOPSIS
 .B lvm dumpconfig
-.RB [ \-f|\-\-file ]
+.RB [ \-f | \-\-file ]
 .IR filename ]
 .RB [ \-\-type
-.IR {current|default|diff|missing|new|profilable}
+.RI { current | default | diff | missing | new | profilable }
 .RB [ \-\-atversion
 .IR version ]
 .RB [ \-\-ignoreadvanced ]
@@ -21,11 +21,12 @@ lvm-dumpconfig \- dump LVM configuration
 lvm dumpconfig produces formatted output with LVM configuration tree.
 
 .SH OPTIONS
-
-.IP "\fB\-f, \-\-file\fP \fI filename"
+.TP
+.BR \-f ", " \-\-file " \fIfilename"
 Dump configuration to a file named 'filename'.
 
-.IP "\fB\-\-type\fP \fI {current|default|diff|missing|new|profilable}"
+.TP
+.IR \fB\-\-type " {" current | default | diff | missing | new | profilable }
 Select the type of configuration to dump. The configuration settings dumped
 have either default values or currently used values assigned based on the
 type selected (if no type is selected, \fB\-\-type current\fP is used
@@ -56,7 +57,8 @@ Dump all profilable configuration settings with default values assigned.
 See \fBlvm.conf\fP(5) for more info about \fBprofile config\fP method.
 .RE
 
-.IP "\fB\-\-atversion\fP version"
+.TP
+.BI \-\-atversion " version"
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 When configuration is dumped, the configuration settings recognized
@@ -65,30 +67,36 @@ to dump a configuration that certain LVM version understands and
 which does not contain any newer settings for which LVM would
 issue a warning message when checking the configuration.
 
-.IP "\fB\-\-ignoreadvanced\fP"
+.TP
+.B \-\-ignoreadvanced
 Ignore advanced configuration settings on dump.
 
-.IP "\fB\-\-ignoreunsupported\fP"
+.TP
+.B \-\-ignoreunsupported
 Ignore unsupported configuration settings on dump. These settings are
 either used for debugging purposes only or their support is not yet
 complete and they are not meant to be used in production.
 
-.IP "\fB\-\-mergedconfig\fP"
+.TP
+.B \-\-mergedconfig
 When the dumpconfig command is run with the \fB\-\-config\fP option
 (a common option that is recognized by all LVM tools, see also
 \fBlvm\fP(8)), merge this configuration with current configuration
 used (see \fB\-\-type current\fP above). Otherwise, only the
 configuration specified within \fB\-\-config\fP option is dumped.
 
-.IP "\fB\-\-validate\fP"
+.TP
+.B \-\-validate
 Validate current configuration used and exit with appropriate
 return code. The validation is done even if \fBconfig/checks\fP
 \fBlvm.conf\fP(5) option is disabled.
 
-.IP "\fB\-\-withcomments\fP"
+.TP
+.B \-\-withcomments
 Also dump comments for each configuration node.
 
-.IP "\fB\-\-withversions\fP"
+.TP
+.B \-\-withversions
 Also dump a comment containing the version of introduction for
 each configuration node.
 


