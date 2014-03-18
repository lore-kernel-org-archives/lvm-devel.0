From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 18 Mar 2014 07:34:28 +0000 (UTC)
Subject: master - doc: cleanup/extend some man pages/conf comments
Message-ID: <20140318073428.2D0A060D82@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64086c3bd827c3f276886125711b112e87bcfd03
Commit:        64086c3bd827c3f276886125711b112e87bcfd03
Parent:        31b1d06dddbab131f85909315dcd1e2d3d6c4562
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 18 08:28:58 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 18 08:28:58 2014 +0100

doc: cleanup/extend some man pages/conf comments

man/lvm2-activation-generator.8:
  Generator Specification -> Generators Specification
  (this is the exact word in the systemd man page)

conf/example.conf.in:
  cleanup recent edits related to report section

man/lvm.conf.5:
  add a line about a possibility to generate a new
  profile with lvm dumpconfig command as an alternative
  to copying the default profile
---
 conf/example.conf.in               |    6 +++---
 man/lvm.conf.5.in                  |   18 ++++++++++++------
 man/lvm2-activation-generator.8.in |    2 +-
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 46ae461..f54ab8d 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -978,15 +978,15 @@ activation {
     polling_interval = 15
 }
 
-# Reporting settings.
+# Report settings.
 #
 # report {
     # Align columns on report output.
     # aligned=1
 
     # When buffered reporting is used, the report's content is appended
-    # incrementally for each object being reported until the report is
-    # flushed to output which normally happens at the end of command
+    # incrementally to include each object being reported until the report
+    # is flushed to output which normally happens at the end of command
     # execution. Otherwise, if buffering is not used, each object is
     # reported as soon as its processing is finished.
     # buffered=1
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 73fcf47..099c5a7 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -23,12 +23,18 @@ See \fBtags\fP configuration setting description below.
 A profile is a set of selected customizable configuration settings
 that are aimed to achieve a certain characteristics in various
 environments or uses. Normally, the name of the profile should
-reflect that environment or use. LVM itself provides a few predefined
-configuration profiles. Users are allowed to add more profiles
-with different values if needed. For this purpose, there's the \fBdefault.profile\fP
-which contains all settings that are customizable by profiles
-and users are encouraged to copy this profile, then to change the values
-as needed and to remove the settings that are not customized by the new profile.
+reflect that environment or use.
+
+LVM itself provides a few predefined configuration profiles.
+Users are allowed to add more profiles with different values if needed.
+For this purpose, there's the \fBdefault.profile\fP which contains all
+settings that are customizable by profiles. Users are encouraged
+to copy this default profile and edit it as needed. Alternatively,
+the \fBlvm dumpconfig --file <ProfileName.profile> --type profilable <section>\fP
+can be used to generate a configuration with profilable settings for
+given section and save it to new ProfileName.profile (if the section
+is not specified, all profilable settings are reported).
+
 The profiles are stored in #DEFAULT_PROFILE_DIR# directory by default.
 This location can be changed using the \fBconfig/profile_dir\fP setting.
 Each profile configuration is stored in \fBProfileName.profile\fP file
diff --git a/man/lvm2-activation-generator.8.in b/man/lvm2-activation-generator.8.in
index bd47397..180b8da 100644
--- a/man/lvm2-activation-generator.8.in
+++ b/man/lvm2-activation-generator.8.in
@@ -40,7 +40,7 @@ since such LVM volumes are activated automatically as soon as the Volume Group
 is ready (all the Physical Volumes making up the Volume Group are present
 in the system).
 
-The lvm2-activation-generator implements the \fBGenerator Specification\fP
+The lvm2-activation-generator implements the \fBGenerators Specification\fP
 as referenced in \fBsystemd\fP(1).
 .sp
 .SH SEE ALSO


