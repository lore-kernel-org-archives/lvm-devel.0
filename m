From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 May 2014 09:01:27 +0000 (UTC)
Subject: master - man: update dumpconfig man page for latest changes
Message-ID: <20140521090127.657E961481@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97c91b020e234d40a43ccde9edc2e8f9a4c3bb2b
Commit:        97c91b020e234d40a43ccde9edc2e8f9a4c3bb2b
Parent:        1ddc68ccd72036d00b6d89c1baa9fa544d093095
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 21 11:00:55 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed May 21 11:01:19 2014 +0200

man: update dumpconfig man page for latest changes

---
 man/lvm-dumpconfig.8.in |   60 +++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 51 insertions(+), 9 deletions(-)

diff --git a/man/lvm-dumpconfig.8.in b/man/lvm-dumpconfig.8.in
index e9fe84e..4b21ef1 100644
--- a/man/lvm-dumpconfig.8.in
+++ b/man/lvm-dumpconfig.8.in
@@ -6,11 +6,19 @@ lvm-dumpconfig \- dump LVM configuration
 .RB [ \-f | \-\-file ]
 .IR filename ]
 .RB [ \-\-type
-.RI { current | default | diff | missing | new | profilable }
+.RI { current | default | diff | missing | new | profilable | profilable-command | profilable-metadata }
 .RB [ \-\-atversion
 .IR version ]
 .RB [ \-\-ignoreadvanced ]
 .RB [ \-\-ignoreunsupported ]
+.RB [ \-\-config
+.IR ConfigurationString ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [ \-\-profile
+.IR ProfileName ]
+.RB [ \-\-metadataprofile
+.IR ProfileName ]
 .RB [ \-\-mergedconfig ]
 .RB [ \-\-validate ]
 .RB [ \-\-withcomments ]
@@ -55,6 +63,14 @@ or specific version as defined by \fB\-\-atversion\fP option.
 .IP profilable 3
 Dump all profilable configuration settings with default values assigned.
 See \fBlvm.conf\fP(5) for more info about \fBprofile config\fP method.
+.IP profilable-command 3
+Dump all profilable configuration settings with default values assigned
+that can be used in command profile. This is a subset of settings dumped
+by \fB\-\-type \-\-profilable\fP.
+.IP profilable-metadata 3
+Dump all profilable configuration settings with default values assigned
+that can be used in metadata profile. This is a subset of settings dumped
+by \fB\-\-type \-\-profilable\fP.
 .RE
 
 .TP
@@ -78,20 +94,46 @@ either used for debugging purposes only or their support is not yet
 complete and they are not meant to be used in production.
 
 .TP
+.BI \-\-config " ConfigurationString"
+Use \fBConfigurationString\fP to override existing configuration.
+This configuration is then applied for dumpconfig command itself.
+See also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP.
+
+.TP
+.BI \-\-commandprofile " ProfileName"
+Use \fBProfileName\fP to override existing configuration.
+This configuration is then applied for dumpconfig command itself.
+See also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP.
+
+.TP
+.BI \-\-profile " ProfileName"
+The same as using \fB\-\-commandprofile\fP but the configuration is not
+applied for dumpconfig command itself.
+
+.TP
+.BI \-\-metadataprofile " ProfileName"
+Use \fBProfileName\fP to override existing configuration.
+The configuration defined in metadata profile has no effect for
+dumpconfig command itself, the dumpconfig dumps the configuration only.
+See also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP.
+
+.TP
 .B \-\-mergedconfig
 When the dumpconfig command is run with the \fB\-\-config\fP option
-and/or \fB\-\-profile\fP option (common options that are recognized
-by all LVM tools, see also \fBlvm\fP(8)), merge the \fB\-\-config\fP
-and/or \fB\-\-profile\fP config with current configuration used
-(see \fB\-\-type current\fP above). Otherwise, only the configuration
-specified within \fB\-\-config\fP or \fB\-\-profile\fP option is dumped
-(see also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP).
+and/or \fB\-\-commandprofile\fP, \fB\-\-profile\fP, \fB\-\-metadataprofile\fP
+option, merge all the contents of the \fBconfig cascade\fP before dumping it.
+Without the \fB\-\-mergeconfig\fP option used, only the configuration at
+the front of the cascade is dumped. See also \fBlvm.conf\fP(5) for more
+info about \fBconfig cascade\fP.
 
 .TP
 .B \-\-validate
 Validate current configuration used and exit with appropriate
-return code. The validation is done even if \fBconfig/checks\fP
-\fBlvm.conf\fP(5) option is disabled.
+return code. The validation is done only for the configuration
+at the front of the \fBconfig cascade\fP. To validate the whole
+merged configuration tree, use also the \fB\-\-mergedconfig\fP option.
+The validation is done even if \fBconfig/checks\fP \fBlvm.conf\fP(5)
+option is disabled.
 
 .TP
 .B \-\-withcomments


