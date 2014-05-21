From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 May 2014 11:25:27 +0000 (UTC)
Subject: master - man: update lvm.conf man page for latest changes
Message-ID: <20140521112527.8610A60F7C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7431f69ed0e8b3b153b5c5dc1e3fbf990d059b0
Commit:        b7431f69ed0e8b3b153b5c5dc1e3fbf990d059b0
Parent:        23f9c45a1bd610c455eb24a1264c07b27cd89fd2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 21 13:25:09 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed May 21 13:25:09 2014 +0200

man: update lvm.conf man page for latest changes

---
 man/lvm.conf.5.in |   90 ++++++++++++++++++++++++++++++++--------------------
 1 files changed, 55 insertions(+), 35 deletions(-)

diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 1bed3d9..e64e2a3 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -13,62 +13,82 @@ any have changed, all the files are reloaded.
 The settings defined in lvm.conf can be overridden by any
 of these extended configuration methods:
 .TP
-.B tag config
-.br
-See \fBtags\fP configuration setting description below.
+.B direct config override on command line
+The \fB\-\-config ConfigurationString\fP command line option takes the
+ConfigurationString as direct string representation of the configuration
+to override the existing configuration. The ConfigurationString is of
+exactly the same format as used in any LVM configuration file.
 
 .TP
 .B profile config
 .br
 A profile is a set of selected customizable configuration settings
 that are aimed to achieve a certain characteristics in various
-environments or uses. Normally, the name of the profile should
-reflect that environment or use.
+environments or uses. It's used to override existing configuration.
+Normally, the name of the profile should reflect that environment or use.
+
+There are two groups of profiles recognised: \fBcommand profiles\fP and
+\fBmetadata profiles\fP.
+
+The \fBcommand profile\fP is used to override selected configuration
+settings at global LVM command level - it is applied at the very beginning
+of LVM command execution and it is used throughout the whole time of LVM
+command execution. The command profile is applied by using the
+\fB\-\-commandprofile ProfileName\fP command line option that is recognised by
+all LVM2 commands.
+
+The \fBmetadata profile\fP is used to override selected configuration
+settings at Volume Group/Logical Volume level - it is applied independently
+for each Volume Group/Logical Volume that is being processed. As such,
+each Volume Group/Logical Volume can store the profile name used
+in its metadata so next time the Volume Group/Logical Volume is
+processed, the profile is applied automatically. If Volume Group and
+any of its Logical Volumes have different profiles defined, the profile
+defined for the Logical Volume is preferred. The metadata profile can be
+attached/detached by using the \fBlvchange\fP and \fBvgchange\fP commands
+and their \fB\-\-metadataprofile ProfileName\fP and
+\fB\-\-detachprofile ProfileName\fP options or the \fB\-\-metadataprofile\fP
+option during creation when using \fBvgcreate\fP or \fBlvcreate\fP command.
+The \fBvgs\fP and \fBlvs\fP reporting commands provide \fB-o vg_profile\fP
+and \fB-o lv_profile\fP output options to show the metadata profile
+currently attached to a Volume Group or a Logical Volume.
+
+The set of options allowed for command profiles is mutually exclusive
+when compared to the set of options allowed for metadata profiles. The
+settings that belong to either of these two sets can't be mixed together
+and LVM tools will reject such profiles.
 
 LVM itself provides a few predefined configuration profiles.
 Users are allowed to add more profiles with different values if needed.
-For this purpose, there's the \fBdefault.profile\fP which contains all
-settings that are customizable by profiles. Users are encouraged
-to copy this default profile and edit it as needed. Alternatively,
-the \fBlvm dumpconfig --file <ProfileName.profile> --type profilable <section>\fP
-can be used to generate a configuration with profilable settings for
-given section and save it to new ProfileName.profile (if the section
-is not specified, all profilable settings are reported).
+For this purpose, there's the \fBcommand_profile_template.profile\fP
+(for command profiles) and \fBmetadata_profile_template.profile\fP
+(for metadata profiles) which contain all settings that are customizable
+by profiles of certain type. Users are encouraged to copy these template
+profiles and edit it as needed. Alternatively, the
+\fBlvm dumpconfig --file <ProfileName.profile> --type profilable-command <section>\fP
+or \fBlvm dumpconfig --file <ProfileName.profile> --type profilable-metadata <section>\fP
+can be used to generate a configuration with profilable settings in either
+of the type for given section and save it to new ProfileName.profile
+(if the section is not specified, all profilable settings are reported).
 
 The profiles are stored in #DEFAULT_PROFILE_DIR# directory by default.
-This location can be changed using the \fBconfig/profile_dir\fP setting.
+This location can be changed by using the \fBconfig/profile_dir\fP setting.
 Each profile configuration is stored in \fBProfileName.profile\fP file
 in the profile directory. When referencing the profile, the \fB.profile\fP
 suffix is left out.
 
-The profile to use can be defined for each LVM command using the \fB\-\-profile ProfileName\fP
-command line option. When using a profile while creating Volume
-Groups or Logical Volumes, the ProfileName is stored in Volume Group
-metadata. When using such volumes later on, the profile is automatically
-loaded and applied. If Volume Group and any of its Logical Volumes have different
-profiles defined, the profile defined for the Logical Volume is used. Profiles
-attached to Volume Groups or Logical Volumes can be changed or detached
-using the \fBvgchange\fP(8) and \fBlvchange\fP(8) commands with \fB\-\-profile ProfileName\fP
-or \fB\-\-detachprofile\fP options. For any other LVM command, the \fB\-\-profile ProfileName\fP
-option causes the profile to be applied only temporarily during the command
-execution for any existing Volume Group or Logical Volume.
-
-The \fBvgs\fP and \fBlvs\fP reporting commands provide \fB-o vg_profile\fP and
-\fB-o lv_profile\fP output options to show the profile currently attached to a
-Volume Group or a Logical Volume.
-
 .TP
-.B direct config override on command line
-The \fB\-\-config ConfigurationString\fP command line option takes the
-ConfigurationString as direct string representation of the configuration
-to override the existing configuration. The ConfigurationString is of
-exactly the same format as used in any LVM configuration file.
+.B tag config
+.br
+See \fBtags\fP configuration setting description below.
 
 .LP
 When several configuration methods are used at the same time
 and when LVM looks for the value of a particular setting, it traverses
 this \fBconfig cascade\fP from left to right:
-\fBdirect config override on command line\fP -> \fBprofile config\fP -> \fBtag config\fP -> \fBlvm.conf\fP.
+
+\fBdirect config override on command line\fP -> \fBcommand profile config\fP -> \fBmetadata profile config\fP -> \fBtag config\fP -> \fBlvm.conf\fP
+
 No part of this cascade is compulsory. If there's no setting value found at
 the end of the cascade, a default value is used for that setting.
 Use \fBlvm dumpconfig\fP to check what settings are in use and what


