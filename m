From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  4 Jul 2013 10:09:46 +0000 (UTC)
Subject: master - man: refine doc for config profiles
Message-ID: <20130704100946.E235860EC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c4f81634f2c53a0ca7a589dbba054ca0c2a4e75
Commit:        2c4f81634f2c53a0ca7a589dbba054ca0c2a4e75
Parent:        0a5b68e87bb901480eb95c98b7811dbb64a54c67
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 4 12:09:21 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 4 12:09:21 2013 +0200

man: refine doc for config profiles

---
 man/lvm.8.in      |   17 ++++++++++-------
 man/lvm.conf.5.in |   16 ++++++++++------
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 129c9fd..61fd74a 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -266,13 +266,16 @@ In addition to that, when creating a Volume Group or a Logical Volume,
 it causes the ProfileName to be stored in metadata for each Volume Group
 or Logical Volume. If the profile is stored in metadata, it is automatically
 applied next time the Volume Group or the Logical Volume is processed and the
-use of --profile is not necessary when running LVM commands further. If different
-profiles are defined for the Volume Group and its Logical Volumes, the profile
-defined for the Logical Volumes are used during command processing. The profile can
-be changed or detached using the \fBvgchange\fP(8) and \fBlvchange\fP(8) command
-and their \fB\-\-profile ProfileName\fP and \fB--detachprofile\fP options.
-See also \fBlvm.conf\fP(5) for more information about configuration profiles
-and the way they fit with other LVM configuration methods.
+use of --profile is not necessary when running LVM commands further. See also
+\fBlvm.conf\fP(5) for more information about \fBprofile config\fP and the
+way it fits with other LVM configuration methods.
+.TP
+.IR \fB\-\-config \ ConfigurationString
+Uses the ConfigurationString as direct string representation of the configuration
+to override the existing configuration. The ConfigurationString is of exactly
+the same format as used in any LVM configuration file. See \fBlvm.conf\fP(5)
+for more information about \fBdirect config override on command line\fP and the
+way it fits with other LVM configuration methods.
 .SH ENVIRONMENT VARIABLES
 .TP
 .B HOME
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 8043f80..2786df2 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -29,7 +29,7 @@ with different values if needed. For this purpose, there's the \fBdefault.profil
 which contains all settings that are customizable by profiles
 and users are encouraged to copy this profile, then to change the values
 as needed and to remove the settings that are not customized by the new profile.
-The profiles are stored in #DEFAULT_PROFILE_DIR# by default.
+The profiles are stored in #DEFAULT_PROFILE_DIR# directory by default.
 This location can be changed using the \fBconfig/profile_dir\fP setting.
 Each profile configuration is stored in \fBProfileName.profile\fP file
 in the profile directory. When referencing the profile, the \fB.profile\fP
@@ -39,13 +39,17 @@ The profile to use can be defined for each LVM command using the \fB\-\-profile
 command line option. When using a profile while creating Volume
 Groups or Logical Volumes, the ProfileName is stored in Volume Group
 metadata. When using such volumes later on, the profile is automatically
-loaded and used. If Volume Group and any of its Logical Volumes has different
+loaded and applied. If Volume Group and any of its Logical Volumes have different
 profiles defined, the profile defined for the Logical Volume is used. Profiles
 attached to Volume Groups or Logical Volumes can be changed or detached
-by using \fBvgchange\fP(8) and \fBlvchange\fP(8) with \fB\-\-profile ProfileName\fP
-or \fB\-\-detachprofile\fP options. The \fBvgs\fP and \fBlvs\fP reporting commands
-provide \fB-o vg_profile\fP and \fB-o lv_profile\fP output options
-to show the profile attached to a Volume Group or a Logical Volume.
+using the \fBvgchange\fP(8) and \fBlvchange\fP(8) commands with \fB\-\-profile ProfileName\fP
+or \fB\-\-detachprofile\fP options. For any other LVM command, the \fB\-\-profile ProfileName\fP
+option causes the profile to be applied only temporarily during the command
+execution for any existing Volume Group or Logical Volume.
+
+The \fBvgs\fP and \fBlvs\fP reporting commands provide \fB-o vg_profile\fP and
+\fB-o lv_profile\fP output options to show the profile currently attached to a
+Volume Group or a Logical Volume.
 
 .TP
 .B direct config override on command line


