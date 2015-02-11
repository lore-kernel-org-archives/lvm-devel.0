From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Feb 2015 09:11:48 +0000 (UTC)
Subject: master - man: dumpconfig: mention LVM_COMMAND_PROFILE env var and add more references to --mergedconfig option
Message-ID: <20150211091148.45E9161044@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3505e88b18edfc60bb06ffccab8dd91f69356c2d
Commit:        3505e88b18edfc60bb06ffccab8dd91f69356c2d
Parent:        801e47e089ae8e1a09164556536d49af555df734
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 11 09:21:08 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 11 09:34:19 2015 +0100

man: dumpconfig: mention LVM_COMMAND_PROFILE env var and add more references to --mergedconfig option

The LVM_COMMAND_PROFILE env var is new - mention it in dumpconfig's
man page.

Also, dumpconfig always displays the top of the config cascade.
To display all the config found in the cascade merged (just like
it's used during LVM command processing), --mergedconfig option
must be used - this one's already described in that man page,
just make sure it's clear and add reference for this option also
in --profile/--commandprofile/--metadataprofile description.
---
 man/lvm-dumpconfig.8.in |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/man/lvm-dumpconfig.8.in b/man/lvm-dumpconfig.8.in
index 844f8ac..04afce9 100644
--- a/man/lvm-dumpconfig.8.in
+++ b/man/lvm-dumpconfig.8.in
@@ -103,7 +103,8 @@ See also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP.
 .BI \-\-commandprofile " ProfileName"
 Use \fBProfileName\fP to override existing configuration.
 This configuration is then applied for dumpconfig command itself.
-See also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP.
+See also \fB\-\-mergedconfig\fP option and \fBlvm.conf\fP(5) for
+more info about \fBconfig cascade\fP.
 
 .TP
 .BI \-\-profile " ProfileName"
@@ -115,12 +116,14 @@ applied for dumpconfig command itself.
 Use \fBProfileName\fP to override existing configuration.
 The configuration defined in metadata profile has no effect for
 dumpconfig command itself, the dumpconfig dumps the configuration only.
-See also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP.
+See also \fB\-\-mergedconfig\fP option and \fBlvm.conf\fP(5) for more
+info about \fBconfig cascade\fP.
 
 .TP
 .B \-\-mergedconfig
 When the dumpconfig command is run with the \fB\-\-config\fP option
-and/or \fB\-\-commandprofile\fP, \fB\-\-profile\fP, \fB\-\-metadataprofile\fP
+and/or \fB\-\-commandprofile\fP (or using \fBLVM_COMMAND_PROFILE\fP
+environment variable), \fB\-\-profile\fP, \fB\-\-metadataprofile\fP
 option, merge all the contents of the \fBconfig cascade\fP before dumping it.
 Without the \fB\-\-mergeconfig\fP option used, only the configuration at
 the front of the cascade is dumped. See also \fBlvm.conf\fP(5) for more


