From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 27 Mar 2014 13:03:43 +0000 (UTC)
Subject: master - man: add man page for lvm dumpconfig
Message-ID: <20140327130343.C929D60F09@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=801d43445dee66a95f15f447a9384cd3f3037199
Commit:        801d43445dee66a95f15f447a9384cd3f3037199
Parent:        c7a89323f53c791e907478a7338a1bdbbb151fe1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 27 14:01:15 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 27 14:03:28 2014 +0100

man: add man page for lvm dumpconfig

---
 WHATS_NEW               |    1 +
 man/Makefile.in         |    3 +-
 man/lvm-dumpconfig.8.in |   97 +++++++++++++++++++++++++++++++++++++++++++++++
 man/lvm.8.in            |    1 +
 4 files changed, 101 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9cda1d5..8013f1e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Add man page for lvm dumpconfig.
   Drop unused cmd pointer for internal function for_each_sub_lv().
   Validate name for renamed sub LVs.
   When lvrename fails on argument parsing return invalid cmd line error (5->3).
diff --git a/man/Makefile.in b/man/Makefile.in
index 40145f1..72098e6 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -41,7 +41,8 @@ LVMETAD =
 endif
 
 MAN5=lvm.conf.5
-MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
+MAN8=lvm-dumpconfig.8 \
+	lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
 	lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
 	lvscan.8 pvchange.8 pvck.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
diff --git a/man/lvm-dumpconfig.8.in b/man/lvm-dumpconfig.8.in
new file mode 100644
index 0000000..0240639
--- /dev/null
+++ b/man/lvm-dumpconfig.8.in
@@ -0,0 +1,97 @@
+.TH "LVM-DUMPCONFIG" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.SH "NAME"
+lvm-dumpconfig \- dump LVM configuration
+.SH SYNOPSIS
+.B lvm dumpconfig
+.RB [ \-f|\-\-file ]
+.IR filename ]
+.RB [ \-\-type
+.IR {current|default|diff|missing|new|profilable}
+.RB [ \-\-atversion
+.IR version ]
+.RB [ \-\-ignoreadvanced ]
+.RB [ \-\-ignoreunsupported ]
+.RB [ \-\-mergedconfig ]
+.RB [ \-\-validate ]
+.RB [ \-\-withcomments ]
+.RB [ \-\-withversions ]
+.RB [ ConfigurationNode... ]
+
+.SH DESCRIPTION
+lvm dumpconfig produces formatted output with LVM configuration tree.
+
+.SH OPTIONS
+
+.IP "\fB\-f, \-\-file\fP \fI filename"
+Dump configuration to a file named 'filename'.
+
+.IP "\fB\-\-type\fP \fI {current|default|diff|missing|new|profilable}"
+Select the type of configuration to dump. The configuration settings dumped
+have either default values or currently used values assigned based on the
+type selected (if no type is selected, \fB\-\-type current\fP is used
+by default). Whenever a configuration setting with a default value is
+commented out, it means the setting does not have any concrete default
+value defined. All output can be saved and reused as proper \fBlvm.conf\fP(5)
+file.
+.RS
+.IP current 3
+Dump current \fBlvm.conf\fP configuration merged with any \fBtag config\fP
+if used. See also \fBlvm.conf\fP(5) for more info about LVM configuration methods.
+.IP default 3
+Dump all possible configuration settings with default values assigned.
+.IP diff 3
+Dump all configuration settings for which the values used differ from defaults.
+The value assigned for each configuration setting is the value currently used.
+This is actually minimal LVM configuration which can be used without
+a change to current configured behaviour.
+.IP missing 3
+Dump all configuration settings with default values assigned which are
+missing in the configuration currently used and for which LVM automatically
+fallbacks to using these default values.
+.IP new 3
+Dump all new configuration settings introduced in current LVM version
+or specific version as defined by \fB\-\-atversion\fP option.
+.IP profilable 3
+Dump all profilable configuration settings with default values assigned.
+See \fBlvm.conf\fP(5) for more info about \fBprofile config\fP method.
+.RE
+
+.IP "\fB\-\-atversion\fP version"
+Specify an LVM version in x.y.z format where x is the major version,
+the y is the minor version and z is the patchlevel (e.g. 2.2.106).
+When configuration is dumped, the configuration settings recognized
+at this LVM version will be considered only. This can be used
+to dump a configuration that certain LVM version understands and
+which does not contain any newer settings for which LVM would
+issue a warning message when checking the configuration.
+
+.IP "\fB\-\-ignoreadvanced\fP"
+Ignore advanced configuration settings on dump.
+
+.IP "\fB\-\-ignoreunsupported\fP"
+Ignore unsupported configuration settings on dump. These settings are
+either used for debugging purposes only or their support is not yet
+complete and they are not meant to be used in production.
+
+.IP "\fB\-\-mergedconfig\fP"
+When the dumpconfig command is run with the \fB\-\-config\fP option
+(a common option that is recognized by all LVM tools, see also
+\fBlvm\fP(8)), merge this configuration with current configuration
+used (see \fB\-\-type current\fP above). Otherwise, only the
+configuration specified within \fB\-\-config\fP option is dumped.
+
+.IP "\fB\-\-validate\fP"
+Validate current configuration used and exit with appropriate
+return code. The validation is done even if \fBconfig/checks\fP
+\fBlvm.conf\fP(5) option is disabled.
+
+.IP "\fB\-\-withcomments\fP"
+Also dump comments for each configuration node.
+
+.IP "\fB\-\-withversions\fP"
+Also dump a comment containing the version of introduction for
+each configuration node.
+
+.SH SEE ALSO
+.BR lvm (8)
+.BR lvm.conf (5)
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 39e47d3..f6335ed 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -588,6 +588,7 @@ All tools return a status code of zero on success or non-zero on failure.
 .I $HOME/.lvm_history
 .SH SEE ALSO
 .BR lvm.conf (5),
+.BR lvm\ dumpconfig (8),
 .BR clvmd (8),
 .BR lvchange (8),
 .BR lvcreate (8),


