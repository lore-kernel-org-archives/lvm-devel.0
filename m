From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 29 Apr 2015 15:05:33 +0000 (UTC)
Subject: master - man: 'lvm config' is preferred over 'lvm lvmconfig'
Message-ID: <20150429150533.44D1661058@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0ff3e9982f1812435bf294d18f743762c944eb1
Commit:        f0ff3e9982f1812435bf294d18f743762c944eb1
Parent:        79ec8eb93ca9620d69cdf8ca294f76a53e652cfe
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 29 10:04:28 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 29 10:04:28 2015 -0500

man: 'lvm config' is preferred over 'lvm lvmconfig'

---
 man/lvm.8.in      |    2 +-
 man/lvm.conf.5.in |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 3d408fb..7ed35c8 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -321,7 +321,7 @@ way it fits with other LVM configuration methods.
 A short form of \fB\-\-metadataprofile\fP for \fBvgcreate\fP, \fBlvcreate\fP,
 \fBvgchange\fP and \fBlvchange\fP command and a short form of \fB\-\-commandprofile\fP
 for any other command (with the exception of \fBlvmconfig\fP command where the
-\-\-profile has special meaning, see \fBlvm lvmconfig\fP(8) for more information).
+\-\-profile has special meaning, see \fBlvm config\fP(8) for more information).
 .TP
 .IR \fB\-\-config " " \fIConfigurationString
 Uses the ConfigurationString as direct string representation of the configuration
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 517c0f9..88694a1 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -65,8 +65,8 @@ For this purpose, there's the \fBcommand_profile_template.profile\fP
 (for metadata profiles) which contain all settings that are customizable
 by profiles of certain type. Users are encouraged to copy these template
 profiles and edit them as needed. Alternatively, the
-\fBlvm lvmconfig \-\-file <ProfileName.profile> \-\-type profilable-command <section>\fP
-or \fBlvm lvmconfig \-\-file <ProfileName.profile> \-\-type profilable-metadata <section>\fP
+\fBlvm config \-\-file <ProfileName.profile> \-\-type profilable-command <section>\fP
+or \fBlvm config \-\-file <ProfileName.profile> \-\-type profilable-metadata <section>\fP
 can be used to generate a configuration with profilable settings in either
 of the type for given section and save it to new ProfileName.profile
 (if the section is not specified, all profilable settings are reported).


