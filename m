From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Apr 2015 16:02:27 +0000 (UTC)
Subject: master - config: Introduce lvmconfig.
Message-ID: <20150428160227.5AAFE60DF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f0434057b8b77efd63fe0c502a962bc9dd13223
Commit:        3f0434057b8b77efd63fe0c502a962bc9dd13223
Parent:        beb229e1e8e8b95de09920195c2bc4171e89dc19
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Apr 28 17:00:37 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Apr 28 17:00:37 2015 +0100

config: Introduce lvmconfig.

'lvm dumpconfig' now does a lot more than just dumping configuration
information and is no longer only a support tool.  Users now need
to run it to find out about configuration information that has been
removed from the lvm.conf man page so we need to promote this to full
command line status as 'lvmconfig'.  Also accept 'lvm config' and mention
it in the usage information of lvmconf (which should also get merged in
eventually).
---
 WHATS_NEW               |    1 +
 man/Makefile.in         |    6 +-
 man/clvmd.8.in          |    2 +-
 man/lvm-config.8.in     |    1 +
 man/lvm-dumpconfig.8.in |  163 +---------------------------------------------
 man/lvm.8.in            |   14 +++--
 man/lvm.conf.5.in       |   22 +++---
 man/lvmconfig.8.in      |  166 +++++++++++++++++++++++++++++++++++++++++++++++
 man/lvmetad.8.in        |    2 +-
 scripts/lvmconf.sh      |    3 +-
 tools/Makefile.in       |    2 +-
 tools/commands.h        |   52 ++++++++++++++-
 tools/dumpconfig.c      |   10 +++
 tools/lvmcmdline.c      |    4 +-
 14 files changed, 261 insertions(+), 187 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ca5ee0f..f0c248c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Introduce lvmconfig as the preferred form of 'lvm dumpconfig'.
   Add lv_ancestors and lv_descendants reporting fields.
   Add --ignorelocal option to dumpconfig to ignore the local section.
   Close connection to lvmetad after fork.
diff --git a/man/Makefile.in b/man/Makefile.in
index a2e19fc..b93c5cb 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -42,9 +42,9 @@ endif
 
 MAN5=lvm.conf.5
 MAN7=lvmsystemid.7
-MAN8=lvm-dumpconfig.8 \
-	lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
-	lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
+MAN8=lvm-config.8 lvm-dumpconfig.8 \
+	lvchange.8 lvmconfig.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 \
+	lvm.8 lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
 	lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
 	lvscan.8 pvchange.8 pvck.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index 9b2bd4e..2c7330b 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -118,7 +118,7 @@ Display the version of the cluster LVM daemon.
 .SH ENVIRONMENT VARIABLES
 .TP
 .B LVM_CLVMD_BINARY
-The CLVMD binary to use when \fBclmvd\fP restart is requested.
+The CLVMD binary to use when \fBclvmd\fP restart is requested.
 Defaults to #CLVMD_PATH#.
 .TP
 .B LVM_BINARY
diff --git a/man/lvm-config.8.in b/man/lvm-config.8.in
new file mode 100644
index 0000000..3d1bec9
--- /dev/null
+++ b/man/lvm-config.8.in
@@ -0,0 +1 @@
+.so man8/lvm-config.8
diff --git a/man/lvm-dumpconfig.8.in b/man/lvm-dumpconfig.8.in
index b16afb4..5050d77 100644
--- a/man/lvm-dumpconfig.8.in
+++ b/man/lvm-dumpconfig.8.in
@@ -1,162 +1 @@
-.TH "LVM-DUMPCONFIG" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-.SH "NAME"
-lvm-dumpconfig \(em dump LVM configuration
-.SH SYNOPSIS
-.B lvm dumpconfig
-.RB [ \-f | \-\-file
-.IR filename ]
-.RB [ \-\-type
-.RI { current | default | diff | missing | new | profilable | profilable-command | profilable-metadata }
-.RB [ \-\-atversion
-.IR version ]
-.RB [ \-\-ignoreadvanced ]
-.RB [ \-\-ignoreunsupported ]
-.RB [ \-\-ignorelocal ]
-.RB [ \-\-config
-.IR ConfigurationString ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-\-profile
-.IR ProfileName ]
-.RB [ \-\-metadataprofile
-.IR ProfileName ]
-.RB [ \-\-mergedconfig ]
-.RB [ \-\-validate ]
-.RB [ \-\-withcomments ]
-.RB [ \-\-withfullcomments ]
-.RB [ \-\-withversions ]
-.RB [ ConfigurationNode... ]
-
-.SH DESCRIPTION
-lvm dumpconfig produces formatted output with LVM configuration tree.
-
-.SH OPTIONS
-.TP
-.BR \-f ", " \-\-file " \fIfilename"
-Dump configuration to a file named 'filename'.
-
-.TP
-.IR \fB\-\-type " {" current | default | diff | missing | new | profilable }
-Select the type of configuration to dump. The configuration settings dumped
-have either default values or currently used values assigned based on the
-type selected (if no type is selected, \fB\-\-type current\fP is used
-by default). Whenever a configuration setting with a default value is
-commented out, it means the setting does not have any concrete default
-value defined. All output can be saved and reused as proper \fBlvm.conf\fP(5)
-file.
-.RS
-.IP current 3
-Dump current \fBlvm.conf\fP configuration merged with any \fBtag config\fP
-if used. See also \fBlvm.conf\fP(5) for more info about LVM configuration methods.
-.IP default 3
-Dump all possible configuration settings with default values assigned.
-.IP diff 3
-Dump all configuration settings for which the values used differ from defaults.
-The value assigned for each configuration setting is the value currently used.
-This is actually minimal LVM configuration which can be used without
-a change to current configured behaviour.
-.IP missing 3
-Dump all configuration settings with default values assigned which are
-missing in the configuration currently used and for which LVM automatically
-fallbacks to using these default values.
-.IP new 3
-Dump all new configuration settings introduced in current LVM version
-or specific version as defined by \fB\-\-atversion\fP option.
-.IP profilable 3
-Dump all profilable configuration settings with default values assigned.
-See \fBlvm.conf\fP(5) for more info about \fBprofile config\fP method.
-.IP profilable-command 3
-Dump all profilable configuration settings with default values assigned
-that can be used in command profile. This is a subset of settings dumped
-by \fB\-\-type \-\-profilable\fP.
-.IP profilable-metadata 3
-Dump all profilable configuration settings with default values assigned
-that can be used in metadata profile. This is a subset of settings dumped
-by \fB\-\-type \-\-profilable\fP.
-.RE
-
-.TP
-.BI \-\-atversion " version"
-Specify an LVM version in x.y.z format where x is the major version,
-the y is the minor version and z is the patchlevel (e.g. 2.2.106).
-When configuration is dumped, the configuration settings recognized
-at this LVM version will be considered only. This can be used
-to dump a configuration that certain LVM version understands and
-which does not contain any newer settings for which LVM would
-issue a warning message when checking the configuration.
-
-.TP
-.B \-\-ignoreadvanced
-Ignore advanced configuration settings on dump.
-
-.TP
-.B \-\-ignoreunsupported
-Ignore unsupported configuration settings on dump. These settings are
-either used for debugging purposes only or their support is not yet
-complete and they are not meant to be used in production.
-
-.TP
-.B \-\-ignorelocal
-Ignore local section.
-
-.TP
-.BI \-\-config " ConfigurationString"
-Use \fBConfigurationString\fP to override existing configuration.
-This configuration is then applied for dumpconfig command itself.
-See also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP.
-
-.TP
-.BI \-\-commandprofile " ProfileName"
-Use \fBProfileName\fP to override existing configuration.
-This configuration is then applied for dumpconfig command itself.
-See also \fB\-\-mergedconfig\fP option and \fBlvm.conf\fP(5) for
-more info about \fBconfig cascade\fP.
-
-.TP
-.BI \-\-profile " ProfileName"
-The same as using \fB\-\-commandprofile\fP but the configuration is not
-applied for dumpconfig command itself.
-
-.TP
-.BI \-\-metadataprofile " ProfileName"
-Use \fBProfileName\fP to override existing configuration.
-The configuration defined in metadata profile has no effect for
-dumpconfig command itself, the dumpconfig dumps the configuration only.
-See also \fB\-\-mergedconfig\fP option and \fBlvm.conf\fP(5) for more
-info about \fBconfig cascade\fP.
-
-.TP
-.B \-\-mergedconfig
-When the dumpconfig command is run with the \fB\-\-config\fP option
-and/or \fB\-\-commandprofile\fP (or using \fBLVM_COMMAND_PROFILE\fP
-environment variable), \fB\-\-profile\fP, \fB\-\-metadataprofile\fP
-option, merge all the contents of the \fBconfig cascade\fP before dumping it.
-Without the \fB\-\-mergeconfig\fP option used, only the configuration at
-the front of the cascade is dumped. See also \fBlvm.conf\fP(5) for more
-info about \fBconfig cascade\fP.
-
-.TP
-.B \-\-validate
-Validate current configuration used and exit with appropriate
-return code. The validation is done only for the configuration
-at the front of the \fBconfig cascade\fP. To validate the whole
-merged configuration tree, use also the \fB\-\-mergedconfig\fP option.
-The validation is done even if \fBconfig/checks\fP \fBlvm.conf\fP(5)
-option is disabled.
-
-.TP
-.B \-\-withcomments
-Dump a one line comment for each configuration node.
-
-.TP
-.B \-\-withfullcomments
-Dump a full comment for each configuration node.
-
-.TP
-.B \-\-withversions
-Also dump a comment containing the version of introduction for
-each configuration node.
-
-.SH SEE ALSO
-.BR lvm (8)
-.BR lvm.conf (5)
+.so man8/lvmconfig.8
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 26d94ee..3d408fb 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -43,11 +43,12 @@ path of \fBlvm\fP.
 The following commands are built into lvm without links normally
 being created in the filesystem for them.
 .TP
-\fBdumpconfig\fP \(em Display the configuration information after
-loading \fBlvm.conf\fP(5) and any other configuration files.
+\fBconfig\fP \(em The same as \fBlvmconfig\fP(8) below.
 .TP
 \fBdevtypes\fP \(em Display the recognised built-in block device types.
 .TP
+\fBdumpconfig\fP \(em The same as \fBlvmconfig\fP(8) below.
+.TP
 \fBformats\fP \(em Display recognised metadata formats.
 .TP
 \fBhelp\fP \(em Display the help text.
@@ -136,6 +137,9 @@ Volumes.
 .TP
 \fBlvmchange\fP \(em Change attributes of the Logical Volume Manager.
 .TP
+\fBlvmconfig\fP \(em Display the configuration information after
+loading \fBlvm.conf\fP(5) and any other configuration files.
+.TP
 \fBlvmdiskscan\fP \(em Scan for all devices visible to LVM2.
 .TP
 \fBlvmdump\fP \(em Create lvm2 information dumps for diagnostic purposes.
@@ -316,8 +320,8 @@ way it fits with other LVM configuration methods.
 .IR \fB\-\-profile " " \fIProfileName
 A short form of \fB\-\-metadataprofile\fP for \fBvgcreate\fP, \fBlvcreate\fP,
 \fBvgchange\fP and \fBlvchange\fP command and a short form of \fB\-\-commandprofile\fP
-for any other command (with the exception of \fBdumpconfig\fP command where the
-\-\-profile has special meaning, see \fBlvm dumpconfig\fP(8) for more information).
+for any other command (with the exception of \fBlvmconfig\fP command where the
+\-\-profile has special meaning, see \fBlvm lvmconfig\fP(8) for more information).
 .TP
 .IR \fB\-\-config " " \fIConfigurationString
 Uses the ConfigurationString as direct string representation of the configuration
@@ -529,7 +533,6 @@ Path for the lvmetad socket file.
 .BR lvm.conf (5),
 .BR lvmcache (7),
 .BR lvmthin (7),
-.BR lvm\ dumpconfig (8),
 .BR clvmd (8),
 .BR dmsetup (8),
 .BR lvchange (8),
@@ -537,6 +540,7 @@ Path for the lvmetad socket file.
 .BR lvdisplay (8),
 .BR lvextend (8),
 .BR lvmchange (8),
+.BR lvmconfig (8),
 .BR lvmdiskscan (8),
 .BR lvreduce (8),
 .BR lvremove (8),
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 074e2e9..2c4effc 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -65,8 +65,8 @@ For this purpose, there's the \fBcommand_profile_template.profile\fP
 (for metadata profiles) which contain all settings that are customizable
 by profiles of certain type. Users are encouraged to copy these template
 profiles and edit them as needed. Alternatively, the
-\fBlvm dumpconfig \-\-file <ProfileName.profile> \-\-type profilable-command <section>\fP
-or \fBlvm dumpconfig \-\-file <ProfileName.profile> \-\-type profilable-metadata <section>\fP
+\fBlvm lvmconfig \-\-file <ProfileName.profile> \-\-type profilable-command <section>\fP
+or \fBlvm lvmconfig \-\-file <ProfileName.profile> \-\-type profilable-metadata <section>\fP
 can be used to generate a configuration with profilable settings in either
 of the type for given section and save it to new ProfileName.profile
 (if the section is not specified, all profilable settings are reported).
@@ -91,7 +91,7 @@ this \fBconfig cascade\fP from left to right:
 
 No part of this cascade is compulsory. If there's no setting value found at
 the end of the cascade, a default value is used for that setting.
-Use \fBlvm dumpconfig\fP to check what settings are in use and what
+Use \fBlvmconfig\fP to check what settings are in use and what
 the default values are.
 .SH SYNTAX
 .LP
@@ -158,38 +158,38 @@ with a letter can be left unquoted.
 .SH SETTINGS
 
 The
-.B lvm dumpconfig
+.B lvmconfig
 command prints the LVM configuration settings in various ways.
 See the man page
-.BR lvm-dumpconfig (8).
+.BR lvmconfig (8).
 
 Command to print a list of all possible config settings, with their
 default values:
 .br
-.B lvm dumpconfig \-\-type default
+.B lvmconfig \-\-type default
 
 Command to print a list of all possible config settings, with their
 default values, and a full description of each as a comment:
 .br
-.B lvm dumpconfig \-\-type default --withfullcomments
+.B lvmconfig \-\-type default --withfullcomments
 
 Command to print a list of all possible config settings, with their
 current values (configured, non-default values are shown):
 .br
-.B lvm dumpconfig \-\-type current
+.B lvmconfig \-\-type current
 
 Command to print all config settings that have been configured with a
 different value than the default (configured, non-default values are
 shown):
 .br
-.B lvm dumpconfig \-\-type diff
+.B lvmconfig \-\-type diff
 
 Command to print a single config setting, with its default value,
 and a full description, where "Section" refers to the config section,
 e.g. global, and "Setting" refers to the name of the specific setting,
 e.g. umask:
 .br
-.B lvm dumpconfig \-\-type default --withfullcomments Section/Setting
+.B lvmconfig \-\-type default --withfullcomments Section/Setting
 
 
 .SH FILES
@@ -209,5 +209,5 @@ e.g. umask:
 
 .SH SEE ALSO
 .BR lvm (8)
-.BR lvm-dumpconfig (8)
+.BR lvmconfig (8)
 
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
new file mode 100644
index 0000000..76f8ffe
--- /dev/null
+++ b/man/lvmconfig.8.in
@@ -0,0 +1,166 @@
+.TH "LVMCONFIG" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.SH "NAME"
+lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration 
+.SH SYNOPSIS
+.B lvmconfig
+.RB [ \-f | \-\-file
+.IR filename ]
+.RB [ \-\-type
+.RI { current | default | diff | missing | new | profilable | profilable-command | profilable-metadata }
+.RB [ \-\-atversion
+.IR version ]
+.RB [ \-\-ignoreadvanced ]
+.RB [ \-\-ignoreunsupported ]
+.RB [ \-\-ignorelocal ]
+.RB [ \-\-config
+.IR ConfigurationString ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-\-profile
+.IR ProfileName ]
+.RB [ \-\-metadataprofile
+.IR ProfileName ]
+.RB [ \-\-mergedconfig ]
+.RB [ \-\-validate ]
+.RB [ \-\-withcomments ]
+.RB [ \-\-withfullcomments ]
+.RB [ \-\-withversions ]
+.RB [ ConfigurationNode... ]
+
+.SH DESCRIPTION
+lvmconfig produces formatted output from the LVM configuration tree.
+The command was added in release 2.02.119 and has an identical longer form 
+\fBlvm dumpconfig\fP.
+
+.SH OPTIONS
+.TP
+.BR \-f ", " \-\-file " \fIfilename"
+Send output to a file named 'filename'.
+
+.TP
+.IR \fB\-\-type " {" current | default | diff | missing | new | profilable }
+Select the type of configuration to display. The configuration settings
+displayed have either default values or currently-used values assigned based on
+the type selected. If no type is selected, \fB\-\-type current\fP is used
+by default. Whenever a configuration setting with a default value is
+commented out, it means the setting does not have any concrete default
+value defined. Output can be saved and used as a proper \fBlvm.conf\fP(5)
+file.
+.RS
+.IP current 3
+Display the current \fBlvm.conf\fP configuration merged with any \fBtag
+config\fP if used. See also \fBlvm.conf\fP(5) for more info about LVM
+configuration methods.
+.IP default 3
+Display all possible configuration settings with default values assigned.
+.IP diff 3
+Display all configuration settings for which the values used differ from defaults.
+The value assigned for each configuration setting is the value currently used.
+This is actually minimal LVM configuration which can be used without
+a change to current configured behaviour.
+.IP missing 3
+Display all configuration settings with default values assigned which are
+missing in the configuration currently used and for which LVM automatically
+fallbacks to using these default values.
+.IP new 3
+Display all new configuration settings introduced in current LVM version
+or specific version as defined by \fB\-\-atversion\fP option.
+.IP profilable 3
+Display all profilable configuration settings with default values assigned.
+See \fBlvm.conf\fP(5) for more info about \fBprofile config\fP method.
+.IP profilable-command 3
+Display all profilable configuration settings with default values assigned
+that can be used in command profile. This is a subset of settings displayed
+by \fB\-\-type \-\-profilable\fP.
+.IP profilable-metadata 3
+Display all profilable configuration settings with default values assigned
+that can be used in metadata profile. This is a subset of settings displayed
+by \fB\-\-type \-\-profilable\fP.
+.RE
+
+.TP
+.BI \-\-atversion " version"
+Specify an LVM version in x.y.z format where x is the major version,
+the y is the minor version and z is the patchlevel (e.g. 2.2.106).
+When configuration is displayed, the configuration settings recognized
+at this LVM version will be considered only. This can be used
+to display a configuration that a certain LVM version understands and
+which does not contain any newer settings for which LVM would
+issue a warning message when checking the configuration.
+
+.TP
+.B \-\-ignoreadvanced
+Exclude advanced configuration settings from the output.
+
+.TP
+.B \-\-ignoreunsupported
+Exclude unsupported configuration settings from the output. These settings are
+either used for debugging purposes only or their support is not yet
+complete and they are not meant to be used in production.
+
+.TP
+.B \-\-ignorelocal
+Ignore local section.
+
+.TP
+.BI \-\-config " ConfigurationString"
+Use \fBConfigurationString\fP to override existing configuration.
+This configuration is then applied for the lvmconfig command itself.
+See also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP.
+
+.TP
+.BI \-\-commandprofile " ProfileName"
+Use \fBProfileName\fP to override existing configuration.
+This configuration is then applied for the lvmconfig command itself.
+See also \fB\-\-mergedconfig\fP option and \fBlvm.conf\fP(5) for
+more info about \fBconfig cascade\fP.
+
+.TP
+.BI \-\-profile " ProfileName"
+The same as using \fB\-\-commandprofile\fP but the configuration is not
+applied for the lvmconfig command itself.
+
+.TP
+.BI \-\-metadataprofile " ProfileName"
+Use \fBProfileName\fP to override existing configuration.
+The configuration defined in metadata profile has no effect for
+the lvmconfig command itself. lvmconfig displays the configuration only.
+See also \fB\-\-mergedconfig\fP option and \fBlvm.conf\fP(5) for more
+info about \fBconfig cascade\fP.
+
+.TP
+.B \-\-mergedconfig
+When the lvmconfig command is run with the \fB\-\-config\fP option
+and/or \fB\-\-commandprofile\fP (or using \fBLVM_COMMAND_PROFILE\fP
+environment variable), \fB\-\-profile\fP, \fB\-\-metadataprofile\fP
+option, merge all the contents of the \fBconfig cascade\fP before displaying it.
+Without the \fB\-\-mergeconfig\fP option used, only the configuration at
+the front of the cascade is displayed. See also \fBlvm.conf\fP(5) for more
+info about \fBconfig cascade\fP.
+
+.TP
+.B \-\-validate
+Validate current configuration used and exit with appropriate
+return code. The validation is done only for the configuration
+at the front of the \fBconfig cascade\fP. To validate the whole
+merged configuration tree, use also the \fB\-\-mergedconfig\fP option.
+The validation is done even if \fBconfig/checks\fP \fBlvm.conf\fP(5)
+option is disabled.
+
+.TP
+.B \-\-withcomments
+Display a one line comment for each configuration node.
+
+.TP
+.B \-\-withfullcomments
+Display a full comment for each configuration node.
+
+.TP
+.B \-\-withversions
+Also display a comment containing the version of introduction for
+each configuration node.
+
+.SH SEE ALSO
+.BR lvm (8)
+.BR lvmconf (8)
+.BR lvm.conf (5)
diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index 4f60249..3ea80c9 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -22,7 +22,7 @@ consistent image of the volume groups available in the system.
 lvmetad is used by LVM only if it is enabled in \fBlvm.conf\fP(5) by specifying the
 \fBglobal/use_lvmetad\fP setting. If this is not defined in the LVM configuration
 explicitly then default setting is used instead (see the output of
-\fBlvm dumpconfig \-\-type default global/use_lvmetad\fP command).
+\fBlvmconfig \-\-type default global/use_lvmetad\fP command).
 .SH OPTIONS
 
 To run the daemon in a test environment both the pidfile_path and the
diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index 6c2a167..396f7a1 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -33,7 +33,7 @@ START_STOP_SERVICES=0
 
 function usage
 {
-    echo "usage: $0 <command>"
+    echo "Usage: $0 <command>"
     echo ""
     echo "Commands:"
     echo "Enable clvm:  --enable-cluster [--lockinglibdir <dir>] [--lockinglib <lib>]"
@@ -46,6 +46,7 @@ function usage
     echo "Config file location: --file <configfile>"
     echo "Set services: --services [--mirrorservice] [--startstopservices]"
     echo ""
+    echo "Use the separate command 'lvmconfig' to display configuration information"
 }
 
 function set_default_use_lvmetad_var
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 1d294dd..861ae82 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -168,7 +168,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
-		egrep -v '^ *(|#.*|devtypes|dumpconfig|formats|help|pvdata|segtypes|systemid|tags|version) *$$' > .commands
+		egrep -v '^ *(|#.*|config|devtypes|dumpconfig|formats|help|pvdata|segtypes|systemid|tags|version) *$$' > .commands
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
diff --git a/tools/commands.h b/tools/commands.h
index 64c8bf2..df69c2a 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -28,6 +28,31 @@ xx(e2fsadm,
     extents_ARG, size_ARG, nofsck_ARG, test_ARG)
 *********/
 
+xx(config,
+   "Display and manipulate configuration information",
+   PERMITTED_READ_ONLY,
+   "config\n"
+   "\t[-f|--file filename]\n"
+   "\t[--type {current|default|diff|missing|new|profilable|profilable-command|profilable-metadata}\n"
+   "\t[--atversion version]]\n"
+   "\t[--ignoreadvanced]\n"
+   "\t[--ignoreunsupported]\n"
+   "\t[--ignorelocal]\n"
+   "\t[--config ConfigurationString]\n"
+   "\t[--commandprofile ProfileName]\n"
+   "\t[--profile ProfileName]\n"
+   "\t[--metadataprofile ProfileName]\n"
+   "\t[--mergedconfig]\n"
+   "\t[--validate]\n"
+   "\t[--withcomments]\n"
+   "\t[--withfullcomments]\n"
+   "\t[--unconfigured]\n"
+   "\t[--withversions]\n"
+   "\t[ConfigurationNode...]\n",
+   atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
+   ignoreunsupported_ARG, ignorelocal_ARG, mergedconfig_ARG, metadataprofile_ARG,
+   validate_ARG, withcomments_ARG, withfullcomments_ARG, unconfigured_ARG, withversions_ARG)
+
 xx(devtypes,
    "Display recognised built-in block device types",
    PERMITTED_READ_ONLY,
@@ -55,7 +80,7 @@ xx(devtypes,
    unbuffered_ARG, unquoted_ARG)
 
 xx(dumpconfig,
-   "Dump configuration",
+   "Display and manipulate configuration information",
    PERMITTED_READ_ONLY,
    "dumpconfig\n"
    "\t[-f|--file filename]\n"
@@ -454,6 +479,31 @@ xx(lvmchange,
 
     reset_ARG)
 
+xx(lvmconfig,
+   "Display and manipulate configuration information",
+   PERMITTED_READ_ONLY,
+   "lvmconfig\n"
+   "\t[-f|--file filename]\n"
+   "\t[--type {current|default|diff|missing|new|profilable|profilable-command|profilable-metadata}\n"
+   "\t[--atversion version]]\n"
+   "\t[--ignoreadvanced]\n"
+   "\t[--ignoreunsupported]\n"
+   "\t[--ignorelocal]\n"
+   "\t[--config ConfigurationString]\n"
+   "\t[--commandprofile ProfileName]\n"
+   "\t[--profile ProfileName]\n"
+   "\t[--metadataprofile ProfileName]\n"
+   "\t[--mergedconfig]\n"
+   "\t[--validate]\n"
+   "\t[--withcomments]\n"
+   "\t[--withfullcomments]\n"
+   "\t[--unconfigured]\n"
+   "\t[--withversions]\n"
+   "\t[ConfigurationNode...]\n",
+   atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
+   ignoreunsupported_ARG, ignorelocal_ARG, mergedconfig_ARG, metadataprofile_ARG,
+   validate_ARG, withcomments_ARG, withfullcomments_ARG, unconfigured_ARG, withversions_ARG)
+
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
    PERMITTED_READ_ONLY | ENABLE_ALL_DEVS,
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index d1b4acc..341bffa 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -257,3 +257,13 @@ out:
 
 	return r;
 }
+
+int config(struct cmd_context *cmd, int argc, char **argv)
+{
+	return dumpconfig(cmd, argc, argv);
+}
+
+int lvmconfig(struct cmd_context *cmd, int argc, char **argv)
+{
+	return dumpconfig(cmd, argc, argv);
+}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 26c48f9..78974df 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1286,7 +1286,9 @@ static int _prepare_profiles(struct cmd_context *cmd)
 		 * If --profile is used with dumpconfig, it's used
 		 * to dump the profile without the profile being applied.
 		 */
-		if (!strcmp(cmd->command->name, "dumpconfig"))
+		if (!strcmp(cmd->command->name, "dumpconfig") ||
+		    !strcmp(cmd->command->name, "lvmconfig") ||
+		    !strcmp(cmd->command->name, "config"))
 			return 1;
 
 		/*


