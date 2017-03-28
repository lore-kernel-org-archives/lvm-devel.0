From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 28 Mar 2017 18:19:58 -0400
Subject: master - man: de-duplicate lvmconfig, lvm-config and lvm-dumpconfig manuals
Message-ID: <201703282219.v2SMJwBW007376@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=961bdaf7478b65b9f1d4c23427d347447ed3bf38
Commit:        961bdaf7478b65b9f1d4c23427d347447ed3bf38
Parent:        162552041f58be8ee3fd79accc742568781b56d5
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Mar 29 00:18:59 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Mar 29 00:18:59 2017 +0200

man: de-duplicate lvmconfig, lvm-config and lvm-dumpconfig manuals

---
 man/Makefile.in             |   43 ++++-
 man/lvm-config.8_des        |    5 -
 man/lvm-config.8_pregen     |  471 -------------------------------------------
 man/lvm-dumpconfig.8_des    |    5 -
 man/lvm-dumpconfig.8_pregen |  471 -------------------------------------------
 man/lvmconfig.8_des         |    3 +-
 man/lvmconfig.8_pregen      |    3 +-
 7 files changed, 41 insertions(+), 960 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 6b7e35c..1593ec8 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -32,8 +32,8 @@ LVMRAIDMAN = lvmraid.7
 
 MAN5=lvm.conf.5
 MAN7=lvmsystemid.7 lvmreport.7 
-MAN8=lvm.8 lvmconf.8 lvmdump.8 lvm-config.8 lvm-dumpconfig.8 lvm-fullreport.8 \
-     lvm-lvpoll.8 lvcreate.8 lvchange.8 lvmconfig.8 lvconvert.8 lvdisplay.8 \
+MAN8=lvm.8 lvmconf.8 lvmdump.8 lvm-fullreport.8 lvm-lvpoll.8 \
+     lvcreate.8 lvchange.8 lvmconfig.8 lvconvert.8 lvdisplay.8 \
      lvextend.8 lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
      lvscan.8 pvchange.8 pvck.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
      pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
@@ -41,6 +41,7 @@ MAN8=lvm.8 lvmconf.8 lvmdump.8 lvm-config.8 lvm-dumpconfig.8 lvm-fullreport.8 \
      vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
      vgrename.8 vgs.8 vgscan.8 vgsplit.8 \
      lvmsar.8 lvmsadc.8 lvmdiskscan.8
+MAN8SO=lvmconfig-common.8 lvmconfig.8.tmp lvm-config.8 lvm-dumpconfig.8
 MAN8DM=dmsetup.8 dmstats.8
 MAN8CLUSTER=
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
@@ -122,7 +123,7 @@ TESTMAN=test.gen
 
 include $(top_builddir)/make.tmpl
 
-CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8:%.8=%.8_gen) $(MAN8CLUSTER) \
+CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8:%.8=%.8_gen) $(MAN8CLUSTER) \
 	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM) $(TESTMAN)
 DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
 	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CLVMDMAN) $(CMIRRORDMAN) \
@@ -135,11 +136,11 @@ all: man device-mapper
 
 device-mapper: $(MAN8DM)
 
-man: $(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS)
+man: $(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS)
 
 all_man: man
 
-$(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS): Makefile
+$(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8DM) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS): Makefile
 
 # Test whether or not the man page generator works
 $(TESTMAN): $(MANGENERATOR) Makefile
@@ -191,7 +192,10 @@ endef
 # - multiple (>= 2)
 # - in ' -'
 # - in (cache|thin)-*
-# - in numerical ranges
+# - in ranges
+# - in "$vg-$lv"
+# - in middle of options (e.g. '--use-policies')
+# - in symbolic use (e.g. '->')
 # - in single one in '\\f.-'
 define ESCAPEHYPHENS
 $(SED) -i -e "s+\([^\\]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
@@ -207,6 +211,17 @@ $(SED) -i -e "s+\([^\\]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([0-9]\)-\([0-9]\)+\1\\\-\2+g" \
 	  -e "s+\(\\\f.\)-\([^-]\)+\1\\\-\2+g" \
 	  -e "s+\([[:digit:]]\{4\}\)\\\-\([[:digit:]]\{2\}\)\\\-\([[:digit:]]\{2\}\)+\1-\2-\3+g" $@
+
+endef
+
+define LVMCONFIGHEADER
+	echo ".TH $(1) 8 \"LVM TOOLS #VERSION#\" \"Red Hat, Inc.\"" | $(SED) -e "s+#VERSION#+$(LVM_VERSION)+" > $@
+	echo ".SH NAME\n" >> $@
+	echo "$(2) \\- Display and manipulate configuration information\n" >> $@
+	echo ".\n" >> $@
+	echo ".SH SYNOPSIS\n" >> $@
+	echo "\\fB$(2)\\fP\n" >> $@
+	echo ".so $<" >> $@
 endef
 
 %.5: $(srcdir)/%.5_main
@@ -225,6 +240,22 @@ endef
 	$(SUBSTVARS)
 	$(ESCAPEHYPHENS)
 
+# Create lvmconfig-common.8 to be shared by lvmconfig.8, lvm-config.8 and lvm.dumpconfig.8
+lvmconfig-common.8: lvmconfig.8
+	$(SED) -e "1,6d" $< > $@
+
+# Create headers for lvmconfig, lvm-config and lvm.dumpconfig and share lvmconfig-common.8
+# Needs temporary target to avoid conflict with %8: target above
+lvmconfig.8.tmp: lvmconfig-common.8
+	$(call LVMCONFIGHEADER,LVMCONFIG,lvmconfig)
+	mv $@ $(@:%.8.tmp=%.8)
+
+lvm-config.8: lvmconfig-common.8
+	$(call LVMCONFIGHEADER,LVM-CONFIG,lvm config)
+
+lvm-dumpconfig.8: lvmconfig-common.8
+	$(call LVMCONFIGHEADER,LVM-DUMPCONFIG,lvm dumpconfig)
+
 install_man5: $(MAN5)
 	$(INSTALL) -d $(MAN5DIR)
 	$(INSTALL_DATA) $(MAN5) $(MAN5DIR)/
diff --git a/man/lvm-config.8_des b/man/lvm-config.8_des
deleted file mode 100644
index 046806e..0000000
--- a/man/lvm-config.8_des
+++ /dev/null
@@ -1,5 +0,0 @@
-This command is the same as \fBlvmconfig\fP(8).
-
-lvm config produces formatted output from the LVM configuration tree. The
-sources of the configuration data include \fBlvm.conf\fP(5) and command
-line settings from --config.
diff --git a/man/lvm-config.8_end b/man/lvm-config.8_end
deleted file mode 100644
index e69de29..0000000
diff --git a/man/lvm-config.8_pregen b/man/lvm-config.8_pregen
deleted file mode 100644
index 228fd5d..0000000
--- a/man/lvm-config.8_pregen
+++ /dev/null
@@ -1,471 +0,0 @@
-.TH LVM CONFIG 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
-.SH NAME
-lvm config - Display and manipulate configuration information
-.
-.SH SYNOPSIS
-\fBlvm config\fP
-.br
-    [ \fIoption_args\fP ]
-.br
-    [ \fIposition_args\fP ]
-.br
-.SH DESCRIPTION
-This command is the same as \fBlvmconfig\fP(8).
-
-lvm config produces formatted output from the LVM configuration tree. The
-sources of the configuration data include \fBlvm.conf\fP(5) and command
-line settings from --config.
-.SH USAGE
-\fBlvm config\fP
-.br
-.RS 4
-.ad l
-[ \fB-f\fP|\fB--file\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-l\fP|\fB--list\fP ]
-.ad b
-.br
-.ad l
-[    \fB--atversion\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoreadvanced\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoreunsupported\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignorelocal\fP ]
-.ad b
-.br
-.ad l
-[    \fB--mergedconfig\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--sinceversion\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--showdeprecated\fP ]
-.ad b
-.br
-.ad l
-[    \fB--showunsupported\fP ]
-.ad b
-.br
-.ad l
-[    \fB--validate\fP ]
-.ad b
-.br
-.ad l
-[    \fB--withsummary\fP ]
-.ad b
-.br
-.ad l
-[    \fB--withcomments\fP ]
-.ad b
-.br
-.ad l
-[    \fB--withspaces\fP ]
-.ad b
-.br
-.ad l
-[    \fB--unconfigured\fP ]
-.ad b
-.br
-.ad l
-[    \fB--withversions\fP ]
-.ad b
-.br
-[ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fIString\fP ... ]
-.RE
-
-Common options for lvm:
-.
-.RS 4
-.ad l
-[ \fB-d\fP|\fB--debug\fP ]
-.ad b
-.br
-.ad l
-[ \fB-h\fP|\fB--help\fP ]
-.ad b
-.br
-.ad l
-[ \fB-q\fP|\fB--quiet\fP ]
-.ad b
-.br
-.ad l
-[ \fB-t\fP|\fB--test\fP ]
-.ad b
-.br
-.ad l
-[ \fB-v\fP|\fB--verbose\fP ]
-.ad b
-.br
-.ad l
-[ \fB-y\fP|\fB--yes\fP ]
-.ad b
-.br
-.ad l
-[    \fB--commandprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--config\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--longhelp\fP ]
-.ad b
-.br
-.ad l
-[    \fB--profile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--version\fP ]
-.ad b
-.RE
-.SH OPTIONS
-.HP
-.ad l
-\fB--atversion\fP \fIString\fP
-.br
-Specify an LVM version in x.y.z format where x is the major version,
-the y is the minor version and z is the patchlevel (e.g. 2.2.106).
-When configuration is displayed, the configuration settings recognized
-at this LVM version will be considered only. This can be used
-to display a configuration that a certain LVM version understands and
-which does not contain any newer settings for which LVM would
-issue a warning message when checking the configuration.
-.ad b
-.HP
-.ad l
-\fB--commandprofile\fP \fIString\fP
-.br
-The command profile to use for command configuration.
-See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
-.ad l
-\fB--config\fP \fIString\fP
-.br
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
-or may use section/field syntax.
-See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
-.ad l
-\fB-d\fP|\fB--debug\fP ...
-.br
-Set debug level. Repeat from 1 to 6 times to increase the detail of
-messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
-.ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
-.br
-If set to no, the command will not attempt to use device-mapper.
-For testing and debugging.
-.ad b
-.HP
-.ad l
-\fB-f\fP|\fB--file\fP \fIString\fP
-.br
-Write output to the named file.
-.ad b
-.HP
-.ad l
-\fB-h\fP|\fB--help\fP
-.br
-Display help text.
-.ad b
-.HP
-.ad l
-\fB--ignoreadvanced\fP
-.br
-Exclude advanced configuration settings from the output.
-.ad b
-.HP
-.ad l
-\fB--ignorelocal\fP
-.br
-Ignore local section.
-.ad b
-.HP
-.ad l
-\fB--ignoreunsupported\fP
-.br
-Exclude unsupported configuration settings from the output. These settings are
-either used for debugging and development purposes only or their support is not
-yet complete and they are not meant to be used in production. The \fBcurrent\fP
-and \fBdiff\fP types include unsupported settings in their output by default,
-all the other types ignore unsupported settings.
-.ad b
-.HP
-.ad l
-\fB-l\fP|\fB--list\fP
-.br
-List config settings with summarizing comment. This is the same as using
-options --typeconfig list --withsummary.
-.ad b
-.HP
-.ad l
-\fB--longhelp\fP
-.br
-Display long help text.
-.ad b
-.HP
-.ad l
-\fB--mergedconfig\fP
-.br
-When the command is run with --config
-and/or --commandprofile (or using LVM_COMMAND_PROFILE
-environment variable), --profile, or --metadataprofile,
-merge all the contents of the "config cascade" before displaying it.
-Without merging, only the configuration at the front of the
-cascade is displayed.
-See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
-.ad l
-\fB--metadataprofile\fP \fIString\fP
-.br
-The metadata profile to use for command configuration.
-See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
-.ad l
-\fB--profile\fP \fIString\fP
-.br
-An alias for --commandprofile or --metadataprofile, depending
-on the command.
-.ad b
-.HP
-.ad l
-\fB-q\fP|\fB--quiet\fP ...
-.br
-Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
-.ad b
-.HP
-.ad l
-\fB--showdeprecated\fP
-.br
-Include deprecated configuration settings in the output. These settings
-are deprecated after a certain version. If a concrete version is specified
-with --atversion, deprecated settings are automatically included
-if the specified version is lower than the version in which the settings were
-deprecated. The current and diff types include deprecated settings
-in their output by default, all the other types ignore deprecated settings.
-.ad b
-.HP
-.ad l
-\fB--showunsupported\fP
-.br
-Include unsupported configuration settings in the output. These settings
-are either used for debugging or development purposes only, or their support
-is not yet complete and they are not meant to be used in production. The
-current and diff types include unsupported settings in their
-output by default, all the other types ignore unsupported settings.
-.ad b
-.HP
-.ad l
-\fB--sinceversion\fP \fIString\fP
-.br
-Specify an LVM version in x.y.z format where x is the major version,
-the y is the minor version and z is the patchlevel (e.g. 2.2.106).
-This option is currently applicable only with --typeconfig new
-to display all configuration settings introduced since given version.
-.ad b
-.HP
-.ad l
-\fB-t\fP|\fB--test\fP
-.br
-Run in test mode. Commands will not update metadata.
-This is implemented by disabling all metadata writing but nevertheless
-returning success to the calling function. This may lead to unusual
-error messages in multi-stage operations if a tool relies on reading
-back metadata it believes has changed but hasn't.
-.ad b
-.HP
-.ad l
-\fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
-.br
-See lvmreport(7).
-.ad b
-.HP
-.ad l
-\fB--unconfigured\fP
-.br
-Internal option used for generating config file during build.
-.ad b
-.HP
-.ad l
-\fB--validate\fP
-.br
-Validate current configuration used and exit with appropriate
-return code. The validation is done only for the configuration
-at the front of the "config cascade". To validate the whole
-merged configuration tree, also use --mergedconfig.
-The validation is done even if lvm.conf config/checks is disabled.
-.ad b
-.HP
-.ad l
-\fB-v\fP|\fB--verbose\fP ...
-.br
-Set verbose level. Repeat from 1 to 4 times to increase the detail
-of messages sent to stdout and stderr.
-.ad b
-.HP
-.ad l
-\fB--version\fP
-.br
-Display version information.
-.ad b
-.HP
-.ad l
-\fB--withcomments\fP
-.br
-Display a full comment for each configuration node. For deprecated
-settings, also display comments about deprecation.
-.ad b
-.HP
-.ad l
-\fB--withspaces\fP
-.br
-Where appropriate, add more spaces in output for better readability.
-.ad b
-.HP
-.ad l
-\fB--withsummary\fP
-.br
-Display a one line comment for each configuration node.
-.ad b
-.HP
-.ad l
-\fB--withversions\fP
-.br
-Also display a comment containing the version of introduction for
-each configuration node. If the setting is deprecated, also display
-the version since which it is deprecated.
-.ad b
-.HP
-.ad l
-\fB-y\fP|\fB--yes\fP
-.br
-Do not prompt for confirmation interactively but always assume the
-answer yes. Use with extreme caution.
-(For automatic no, see -qq.)
-.ad b
-.SH VARIABLES
-.HP
-\fIString\fP
-.br
-See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
-Size is an input number that accepts an optional unit.
-Input units are always treated as base two values, regardless of
-capitalization, e.g. 'k' and 'K' both refer to 1024.
-The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
-capital letters mean multiple of 1000.)
-.SH ENVIRONMENT VARIABLES
-See \fBlvm\fP(8) for information about environment variables used by lvm.
-For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
-
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
-
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
-
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
-
-.BR dmeventd (8)
-.BR lvmetad (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR clvmd (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
-
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
-.BR lvmcache (7)
diff --git a/man/lvm-dumpconfig.8_des b/man/lvm-dumpconfig.8_des
deleted file mode 100644
index 3ebe2b3..0000000
--- a/man/lvm-dumpconfig.8_des
+++ /dev/null
@@ -1,5 +0,0 @@
-This command is the same as \fBlvmconfig\fP(8).
-
-lvm dumpconfig produces formatted output from the LVM configuration tree. The
-sources of the configuration data include \fBlvm.conf\fP(5) and command
-line settings from --config.
diff --git a/man/lvm-dumpconfig.8_end b/man/lvm-dumpconfig.8_end
deleted file mode 100644
index e69de29..0000000
diff --git a/man/lvm-dumpconfig.8_pregen b/man/lvm-dumpconfig.8_pregen
deleted file mode 100644
index 90acf5f..0000000
--- a/man/lvm-dumpconfig.8_pregen
+++ /dev/null
@@ -1,471 +0,0 @@
-.TH LVM DUMPCONFIG 8 "LVM TOOLS #VERSION#" "Red Hat, Inc."
-.SH NAME
-lvm dumpconfig - Display and manipulate configuration information
-.
-.SH SYNOPSIS
-\fBlvm dumpconfig\fP
-.br
-    [ \fIoption_args\fP ]
-.br
-    [ \fIposition_args\fP ]
-.br
-.SH DESCRIPTION
-This command is the same as \fBlvmconfig\fP(8).
-
-lvm dumpconfig produces formatted output from the LVM configuration tree. The
-sources of the configuration data include \fBlvm.conf\fP(5) and command
-line settings from --config.
-.SH USAGE
-\fBlvm dumpconfig\fP
-.br
-.RS 4
-.ad l
-[ \fB-f\fP|\fB--file\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[ \fB-l\fP|\fB--list\fP ]
-.ad b
-.br
-.ad l
-[    \fB--atversion\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoreadvanced\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignoreunsupported\fP ]
-.ad b
-.br
-.ad l
-[    \fB--ignorelocal\fP ]
-.ad b
-.br
-.ad l
-[    \fB--mergedconfig\fP ]
-.ad b
-.br
-.ad l
-[    \fB--metadataprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--sinceversion\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--showdeprecated\fP ]
-.ad b
-.br
-.ad l
-[    \fB--showunsupported\fP ]
-.ad b
-.br
-.ad l
-[    \fB--validate\fP ]
-.ad b
-.br
-.ad l
-[    \fB--withsummary\fP ]
-.ad b
-.br
-.ad l
-[    \fB--withcomments\fP ]
-.ad b
-.br
-.ad l
-[    \fB--withspaces\fP ]
-.ad b
-.br
-.ad l
-[    \fB--unconfigured\fP ]
-.ad b
-.br
-.ad l
-[    \fB--withversions\fP ]
-.ad b
-.br
-[ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fIString\fP ... ]
-.RE
-
-Common options for lvm:
-.
-.RS 4
-.ad l
-[ \fB-d\fP|\fB--debug\fP ]
-.ad b
-.br
-.ad l
-[ \fB-h\fP|\fB--help\fP ]
-.ad b
-.br
-.ad l
-[ \fB-q\fP|\fB--quiet\fP ]
-.ad b
-.br
-.ad l
-[ \fB-t\fP|\fB--test\fP ]
-.ad b
-.br
-.ad l
-[ \fB-v\fP|\fB--verbose\fP ]
-.ad b
-.br
-.ad l
-[ \fB-y\fP|\fB--yes\fP ]
-.ad b
-.br
-.ad l
-[    \fB--commandprofile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--config\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
-[    \fB--longhelp\fP ]
-.ad b
-.br
-.ad l
-[    \fB--profile\fP \fIString\fP ]
-.ad b
-.br
-.ad l
-[    \fB--version\fP ]
-.ad b
-.RE
-.SH OPTIONS
-.HP
-.ad l
-\fB--atversion\fP \fIString\fP
-.br
-Specify an LVM version in x.y.z format where x is the major version,
-the y is the minor version and z is the patchlevel (e.g. 2.2.106).
-When configuration is displayed, the configuration settings recognized
-at this LVM version will be considered only. This can be used
-to display a configuration that a certain LVM version understands and
-which does not contain any newer settings for which LVM would
-issue a warning message when checking the configuration.
-.ad b
-.HP
-.ad l
-\fB--commandprofile\fP \fIString\fP
-.br
-The command profile to use for command configuration.
-See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
-.ad l
-\fB--config\fP \fIString\fP
-.br
-Config settings for the command. These override lvm.conf settings.
-The String arg uses the same format as lvm.conf,
-or may use section/field syntax.
-See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
-.ad l
-\fB-d\fP|\fB--debug\fP ...
-.br
-Set debug level. Repeat from 1 to 6 times to increase the detail of
-messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
-.ad l
-\fB--driverloaded\fP \fBy\fP|\fBn\fP
-.br
-If set to no, the command will not attempt to use device-mapper.
-For testing and debugging.
-.ad b
-.HP
-.ad l
-\fB-f\fP|\fB--file\fP \fIString\fP
-.br
-Write output to the named file.
-.ad b
-.HP
-.ad l
-\fB-h\fP|\fB--help\fP
-.br
-Display help text.
-.ad b
-.HP
-.ad l
-\fB--ignoreadvanced\fP
-.br
-Exclude advanced configuration settings from the output.
-.ad b
-.HP
-.ad l
-\fB--ignorelocal\fP
-.br
-Ignore local section.
-.ad b
-.HP
-.ad l
-\fB--ignoreunsupported\fP
-.br
-Exclude unsupported configuration settings from the output. These settings are
-either used for debugging and development purposes only or their support is not
-yet complete and they are not meant to be used in production. The \fBcurrent\fP
-and \fBdiff\fP types include unsupported settings in their output by default,
-all the other types ignore unsupported settings.
-.ad b
-.HP
-.ad l
-\fB-l\fP|\fB--list\fP
-.br
-List config settings with summarizing comment. This is the same as using
-options --typeconfig list --withsummary.
-.ad b
-.HP
-.ad l
-\fB--longhelp\fP
-.br
-Display long help text.
-.ad b
-.HP
-.ad l
-\fB--mergedconfig\fP
-.br
-When the command is run with --config
-and/or --commandprofile (or using LVM_COMMAND_PROFILE
-environment variable), --profile, or --metadataprofile,
-merge all the contents of the "config cascade" before displaying it.
-Without merging, only the configuration at the front of the
-cascade is displayed.
-See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
-.ad l
-\fB--metadataprofile\fP \fIString\fP
-.br
-The metadata profile to use for command configuration.
-See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
-.ad l
-\fB--profile\fP \fIString\fP
-.br
-An alias for --commandprofile or --metadataprofile, depending
-on the command.
-.ad b
-.HP
-.ad l
-\fB-q\fP|\fB--quiet\fP ...
-.br
-Suppress output and log messages. Overrides --debug and --verbose.
-Repeat once to also suppress any prompts with answer no.
-.ad b
-.HP
-.ad l
-\fB--showdeprecated\fP
-.br
-Include deprecated configuration settings in the output. These settings
-are deprecated after a certain version. If a concrete version is specified
-with --atversion, deprecated settings are automatically included
-if the specified version is lower than the version in which the settings were
-deprecated. The current and diff types include deprecated settings
-in their output by default, all the other types ignore deprecated settings.
-.ad b
-.HP
-.ad l
-\fB--showunsupported\fP
-.br
-Include unsupported configuration settings in the output. These settings
-are either used for debugging or development purposes only, or their support
-is not yet complete and they are not meant to be used in production. The
-current and diff types include unsupported settings in their
-output by default, all the other types ignore unsupported settings.
-.ad b
-.HP
-.ad l
-\fB--sinceversion\fP \fIString\fP
-.br
-Specify an LVM version in x.y.z format where x is the major version,
-the y is the minor version and z is the patchlevel (e.g. 2.2.106).
-This option is currently applicable only with --typeconfig new
-to display all configuration settings introduced since given version.
-.ad b
-.HP
-.ad l
-\fB-t\fP|\fB--test\fP
-.br
-Run in test mode. Commands will not update metadata.
-This is implemented by disabling all metadata writing but nevertheless
-returning success to the calling function. This may lead to unusual
-error messages in multi-stage operations if a tool relies on reading
-back metadata it believes has changed but hasn't.
-.ad b
-.HP
-.ad l
-\fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
-.br
-See lvmreport(7).
-.ad b
-.HP
-.ad l
-\fB--unconfigured\fP
-.br
-Internal option used for generating config file during build.
-.ad b
-.HP
-.ad l
-\fB--validate\fP
-.br
-Validate current configuration used and exit with appropriate
-return code. The validation is done only for the configuration
-at the front of the "config cascade". To validate the whole
-merged configuration tree, also use --mergedconfig.
-The validation is done even if lvm.conf config/checks is disabled.
-.ad b
-.HP
-.ad l
-\fB-v\fP|\fB--verbose\fP ...
-.br
-Set verbose level. Repeat from 1 to 4 times to increase the detail
-of messages sent to stdout and stderr.
-.ad b
-.HP
-.ad l
-\fB--version\fP
-.br
-Display version information.
-.ad b
-.HP
-.ad l
-\fB--withcomments\fP
-.br
-Display a full comment for each configuration node. For deprecated
-settings, also display comments about deprecation.
-.ad b
-.HP
-.ad l
-\fB--withspaces\fP
-.br
-Where appropriate, add more spaces in output for better readability.
-.ad b
-.HP
-.ad l
-\fB--withsummary\fP
-.br
-Display a one line comment for each configuration node.
-.ad b
-.HP
-.ad l
-\fB--withversions\fP
-.br
-Also display a comment containing the version of introduction for
-each configuration node. If the setting is deprecated, also display
-the version since which it is deprecated.
-.ad b
-.HP
-.ad l
-\fB-y\fP|\fB--yes\fP
-.br
-Do not prompt for confirmation interactively but always assume the
-answer yes. Use with extreme caution.
-(For automatic no, see -qq.)
-.ad b
-.SH VARIABLES
-.HP
-\fIString\fP
-.br
-See the option description for information about the string content.
-.HP
-\fISize\fP[UNIT]
-.br
-Size is an input number that accepts an optional unit.
-Input units are always treated as base two values, regardless of
-capitalization, e.g. 'k' and 'K' both refer to 1024.
-The default input unit is specified by letter, followed by |UNIT.
-UNIT represents other possible input units: \fBbBsSkKmMgGtTpPeE\fP.
-b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,
-m|M is megabytes, g|G is gigabytes, t|T is terabytes,
-p|P is petabytes, e|E is exabytes.
-(This should not be confused with the output control --units, where
-capital letters mean multiple of 1000.)
-.SH ENVIRONMENT VARIABLES
-See \fBlvm\fP(8) for information about environment variables used by lvm.
-For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
-.SH SEE ALSO
-
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
-
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
-
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
-
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
-
-.BR dmeventd (8)
-.BR lvmetad (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR clvmd (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
-
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
-.BR lvmcache (7)
diff --git a/man/lvmconfig.8_des b/man/lvmconfig.8_des
index 3863d12..2398759 100644
--- a/man/lvmconfig.8_des
+++ b/man/lvmconfig.8_des
@@ -1,3 +1,4 @@
-lvmconfig produces formatted output from the LVM configuration tree. The
+lvmconfig, lvm dumpconfig, lvm config produce
+formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
 line settings from --config.
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 5f2306e..ec076b2 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -10,7 +10,8 @@ lvmconfig - Display and manipulate configuration information
     [ \fIposition_args\fP ]
 .br
 .SH DESCRIPTION
-lvmconfig produces formatted output from the LVM configuration tree. The
+lvmconfig, lvm dumpconfig, lvm config produce
+formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
 line settings from --config.
 .SH USAGE


