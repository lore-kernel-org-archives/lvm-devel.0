From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  3 Jul 2013 14:50:36 +0000 (UTC)
Subject: master - man: document profile config and related options
Message-ID: <20130703145036.98DCC611BF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a5b68e87bb901480eb95c98b7811dbb64a54c67
Commit:        0a5b68e87bb901480eb95c98b7811dbb64a54c67
Parent:        21cd275b37cafa7605451aeeef3f1f7fae98447a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 3 16:45:27 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 3 16:49:26 2013 +0200

man: document profile config and related options

Document following items:
  configuration cascade (man lvm.conf)
  --profile ProfileName (man lvm)
  --detachprofile (man vgchange/lvchange)
  -o vg_profile/lv_profile (man vgs/lvs)

Also document --config a bit so we can see where it fits in the
configuration cascade - will be documented more in following commit...
---
 WHATS_NEW         |    1 +
 man/Makefile.in   |    2 +-
 man/lvchange.8.in |    8 +++++++
 man/lvm.8.in      |   14 ++++++++++++
 man/lvm.conf.5.in |   61 +++++++++++++++++++++++++++++++++++++++++++++++++---
 man/lvs.8.in      |    1 +
 man/vgchange.8.in |    8 +++++++
 man/vgs.8.in      |    6 ++--
 8 files changed, 93 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index adecd63..b174cb3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add man page entries for profile configuration and related options.
   Improve error loging when user tries to interrupt commands.
   Rename _swap_lv to _swap_lv_identifiers and move to allow an additional user.
   Rename snapshot segment returning methods from find_*_cow to find_*_snapshot.
diff --git a/man/Makefile.in b/man/Makefile.in
index 8be34c3..8c2ff13 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -85,7 +85,7 @@ $(MAN5) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 %: %.in
 	@case "$@" in \
 	  */*) ;; \
-	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;" $< > $@ ;; \
+	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;" $< > $@ ;; \
 	esac
 
 install_man5: $(MAN5)
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index d5041f3..44426ef 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -16,6 +16,9 @@ lvchange \- change attributes of a logical volume
 .RB [ \-d | \-\-debug ]
 .RB [ \-\-deltag
 .IR Tag ]
+.RB [ \-\-profile
+.IR ProfileName ]
+.RB [ \-\-detachprofile ]
 .RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
 .RB [ \-\-resync ]
@@ -81,6 +84,11 @@ logical volumes. It's only possible to change a non-contiguous
 logical volume's allocation policy to contiguous, if all of the
 allocated physical extents are already contiguous.
 .TP
+.BR \-\-detachprofile
+Detach any configuration profiles attached to given Logical Volumes.
+See also \fBlvm\fP(8) and \fBlvm.conf\fP(5) for more
+information about configuration profiles.
+.TP
 .BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
 Set this to \fIignore\fP to ignore any discards received by a
 thin pool Logical Volume.  Set to \fInopassdown\fP to process such
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 37a60e4..129c9fd 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -259,6 +259,20 @@ If there are sufficient free Physical Extents to satisfy
 an allocation request but \fInormal\fP doesn't use them,
 \fIanywhere\fP will - even if that reduces performance by
 placing two stripes on the same Physical Volume.
+.TP
+.IR \fB\-\-profile \ ProfileName
+Selects the configuration profile to use when processing an LVM command.
+In addition to that, when creating a Volume Group or a Logical Volume,
+it causes the ProfileName to be stored in metadata for each Volume Group
+or Logical Volume. If the profile is stored in metadata, it is automatically
+applied next time the Volume Group or the Logical Volume is processed and the
+use of --profile is not necessary when running LVM commands further. If different
+profiles are defined for the Volume Group and its Logical Volumes, the profile
+defined for the Logical Volumes are used during command processing. The profile can
+be changed or detached using the \fBvgchange\fP(8) and \fBlvchange\fP(8) command
+and their \fB\-\-profile ProfileName\fP and \fB--detachprofile\fP options.
+See also \fBlvm.conf\fP(5) for more information about configuration profiles
+and the way they fit with other LVM configuration methods.
 .SH ENVIRONMENT VARIABLES
 .TP
 .B HOME
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index f47cc17..8043f80 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -4,13 +4,65 @@ lvm.conf \- Configuration file for LVM2
 .SH SYNOPSIS
 .B #DEFAULT_SYS_DIR#/lvm.conf
 .SH DESCRIPTION
-lvm.conf is loaded during the initialisation phase of
+\fBlvm.conf\fP is loaded during the initialisation phase of
 \fBlvm\fP(8).  This file can in turn lead to other files
 being loaded - settings read in later override earlier
 settings.  File timestamps are checked between commands and if
 any have changed, all the files are reloaded.
+
+The settings defined in lvm.conf can be overridden by any
+of these extended configuration methods:
+.TP
+.B tag config
+.br
+See \fBtags\fP configuration setting description below.
+
+.TP
+.B profile config
+.br
+A profile is a set of selected customizable configuration settings
+that are aimed to achieve a certain characteristics in various
+environments or uses. Normally, the name of the profile should
+reflect that environment or use. LVM itself provides a few predefined
+configuration profiles. Users are allowed to add more profiles
+with different values if needed. For this purpose, there's the \fBdefault.profile\fP
+which contains all settings that are customizable by profiles
+and users are encouraged to copy this profile, then to change the values
+as needed and to remove the settings that are not customized by the new profile.
+The profiles are stored in #DEFAULT_PROFILE_DIR# by default.
+This location can be changed using the \fBconfig/profile_dir\fP setting.
+Each profile configuration is stored in \fBProfileName.profile\fP file
+in the profile directory. When referencing the profile, the \fB.profile\fP
+suffix is left out.
+
+The profile to use can be defined for each LVM command using the \fB\-\-profile ProfileName\fP
+command line option. When using a profile while creating Volume
+Groups or Logical Volumes, the ProfileName is stored in Volume Group
+metadata. When using such volumes later on, the profile is automatically
+loaded and used. If Volume Group and any of its Logical Volumes has different
+profiles defined, the profile defined for the Logical Volume is used. Profiles
+attached to Volume Groups or Logical Volumes can be changed or detached
+by using \fBvgchange\fP(8) and \fBlvchange\fP(8) with \fB\-\-profile ProfileName\fP
+or \fB\-\-detachprofile\fP options. The \fBvgs\fP and \fBlvs\fP reporting commands
+provide \fB-o vg_profile\fP and \fB-o lv_profile\fP output options
+to show the profile attached to a Volume Group or a Logical Volume.
+
+.TP
+.B direct config override on command line
+The \fB\-\-config ConfigurationString\fP command line option takes the
+ConfigurationString as direct string representation of the configuration
+to override the existing configuration. The ConfigurationString is of
+exactly the same format as used in any LVM configuration file.
+
 .LP
-Use \fBlvm dumpconfig\fP to check what settings are in use.
+When several configuration methods are used at the same time
+and when LVM looks for the value of a particular setting, it traverses
+this cascade from left to right:
+\fBdirect config override on command line\fP -> \fBprofile config\fP -> \fBtag config\fP -> \fBlvm.conf\fP.
+No part of this cascade is compulsory. If there's no setting value found at
+the end of the cascade, a default value is used for that setting.
+Use \fBlvm dumpconfig\fP to check what settings are in use and what
+the default values are.
 .SH SYNTAX
 .LP
 This section describes the configuration file syntax.
@@ -389,8 +441,9 @@ otherwise it doesn't.
 After lvm.conf has been processed, LVM2 works through each host
 tag that has been defined in turn, and if there is a configuration
 file called lvm_\fB<host_tag>\fP.conf it attempts to load it.
-Any settings read in override settings found in earlier files.
-Any additional host tags defined get appended to the search list,
+The activation/volume_list, devices/filter and devices/types settings are merged
+(these all are lists), otherwise any settings read in override settings found in
+earlier files. Any additional host tags defined get appended to the search list,
 so in turn they can lead to further configuration files being processed.
 Use \fBlvm dumpconfig\fP to check the result of config
 file processing.
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 1626e17..013740f 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -90,6 +90,7 @@ lv_major,
 lv_minor,
 lv_name,
 lv_path,
+lv_profile,
 lv_read_ahead,
 lv_size,
 lv_tags,
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index bc4ef32..ab76ed0 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -22,6 +22,9 @@ vgchange \- change attributes of a volume group
 .RB [ \-d | \-\-debug ]
 .RB [ \-\-deltag
 .IR Tag ]
+.RB [ \-\-profile
+.IR ProfileName ]
+.RB [ \-\-detachprofile ]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-ignoremonitoring ]
@@ -89,6 +92,11 @@ If the cluster infrastructure is unavailable on a particular node at a
 particular time, you may still be able to use Volume Groups that
 are not marked as clustered.
 .TP
+.BR \-\-detachprofile
+Detach any configuration profiles attached to given Volume Groups.
+See also \fBlvm\fP(8) and \fBlvm.conf\fP(5) for more
+information about configuration profiles.
+.TP
 .BR \-u ", " \-\-uuid
 Generate new random UUID for specified Volume Groups.
 .TP
diff --git a/man/vgs.8.in b/man/vgs.8.in
index e555898..381e3a9 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -60,9 +60,9 @@ Use \fB\-o vg_all\fP to select all volume group columns.
 Use \fB\-o help\fP to view the full list of columns available.
 .IP
 Column names include: vg_fmt, vg_uuid, vg_name, vg_attr, vg_size, vg_free,
-vg_sysid, vg_extent_size, vg_extent_count, vg_free_count, max_lv, max_pv,
-pv_count, lv_count, snap_count, vg_seqno, vg_tags, vg_mda_count, vg_mda_free,
-and vg_mda_size, vg_mda_used_count.
+vg_sysid, vg_extent_size, vg_extent_count, vg_free_count, vg_profile, max_lv,
+max_pv, pv_count, lv_count, snap_count, vg_seqno, vg_tags, vg_mda_count,
+vg_mda_free, and vg_mda_size, vg_mda_used_count.
 .IP
 Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs\fP(8)
 or \fBlvs\fP(8) can also be chosen, but columns cannot be taken from both


