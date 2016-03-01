From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Mar 2016 13:03:18 +0000 (UTC)
Subject: master - man: fix mising braces
Message-ID: <20160301130318.BAD0960CD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b93c110303de10464ad3e2a4b14175526765832
Commit:        3b93c110303de10464ad3e2a4b14175526765832
Parent:        872d5922e17692332df3ee3bebeb1dac0855887d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 1 13:40:32 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 1 14:02:43 2016 +0100

man: fix mising braces

Fixing some reported issued found by:
http://catb.org/~esr/doclifter/bugs.html

Reported-by: Eric S. Raymond <esr@thyrsus.com>
---
 man/lvmconfig.8.in |   37 +++++++++++++++++++++----------------
 man/lvresize.8.in  |    6 +++---
 2 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index 0e9e7c5..9a3fcab 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -2,14 +2,18 @@
 .SH "NAME"
 lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration 
 .SH SYNOPSIS
+.
+.ad l
 .B lvmconfig
 .RB [ \-f | \-\-file
 .IR filename ]
 .RB [ \-\-type
-.RI { current | default | diff | full | list | missing | new | profilable | profilable-command | profilable-metadata }
+.RB { current |\: default |\: diff |\: full | list |\: missing \c
+.RB |\: new |\: profilable |\: profilable-command \c
+.RB |\: profilable-metadata }]
 .RB [ \-\-atversion
 .IR version ]
-.RB [ \-\---sinceversion
+.RB [ \-\-sinceversion
 .IR version ]
 .RB [ \-\-ignoreadvanced ]
 .RB [ \-\-ignoreunsupported ]
@@ -32,7 +36,8 @@ lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration
 .RB [ \-\-withspaces ]
 .RB [ \-\-withversions ]
 .RB [ ConfigurationNode... ]
-
+.ad b
+.
 .SH DESCRIPTION
 lvmconfig produces formatted output from the LVM configuration tree.
 The command was added in release 2.02.119 and has an identical longer form 
@@ -49,7 +54,7 @@ List configuration settings with summarizing comment. This is the same as using
 \fBlvmconfig --type list --withsummary\fP.
 
 .TP
-.IR \fB\-\-type " {" current | default | diff | full | missing | new | profilable | profilable-command | profilable-metadata }
+.BR \-\-type " {" current | default | diff | full | missing | new | profilable | profilable-command | profilable-metadata }
 Select the type of configuration to display. The configuration settings
 displayed have either default values or currently-used values assigned based on
 the type selected. If no type is selected, \fB\-\-type current\fP is used
@@ -58,18 +63,18 @@ commented out, it means the setting does not have any concrete default
 value defined. Output can be saved and used as a proper \fBlvm.conf\fP(5)
 file.
 .RS
-.IP current 3
+.IP \fBcurrent\fP 3
 Display the current \fBlvm.conf\fP configuration merged with any \fBtag
 config\fP if used. See also \fBlvm.conf\fP(5) for more info about LVM
 configuration methods.
-.IP default 3
+.IP \fBdefault\fP 3
 Display all possible configuration settings with default values assigned.
-.IP diff 3
+.IP \fBdiff\fP 3
 Display all configuration settings for which the values used differ from defaults.
 The value assigned for each configuration setting is the value currently used.
 This is actually minimal LVM configuration which can be used without
 a change to current configured behaviour.
-.IP full 3
+.IP \fBfull\fP 3
 Display full configuration tree - a combination of current configuration tree
 (\fB\-\-type current\fP) and tree of settings for which default values are
 used (\fB\-\-type missing\fP). This is exactly the configuration tree that
@@ -78,26 +83,26 @@ the use of \fB\-\-mergedconfig\fP option. If comments are displayed
 (see \fB\-\-withcomments\fP and \fB\-\-withsummary\fP options), then
 for each setting found in existing configuration and for which defaults
 are not used, there's an extra comment line printed to denote this.
-.IP list 3
+.IP \fBlist\fP 3
 Display plain list of configuration settings.
-.IP missing 3
+.IP \fBmissing\fP 3
 Display all configuration settings with default values assigned which are
 missing in the configuration currently used and for which LVM automatically
 fallbacks to using these default values.
-.IP new 3
+.IP \fBnew\fP 3
 Display all new configuration settings introduced in current LVM version
 or specific version as defined by \fB\-\-atversion\fP option.
-.IP profilable 3
+.IP \fBprofilable\fP 3
 Display all profilable configuration settings with default values assigned.
 See \fBlvm.conf\fP(5) for more info about \fBprofile config\fP method.
-.IP profilable-command 3
+.IP \fBprofilable-command\fP 3
 Display all profilable configuration settings with default values assigned
 that can be used in command profile. This is a subset of settings displayed
-by \fB\-\-type \-\-profilable\fP.
-.IP profilable-metadata 3
+by \fB\-\-type profilable\fP.
+.IP \fBprofilable-metadata\fP 3
 Display all profilable configuration settings with default values assigned
 that can be used in metadata profile. This is a subset of settings displayed
-by \fB\-\-type \-\-profilable\fP.
+by \fB\-\-type profilable\fP.
 .RE
 
 .TP
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index ed95a0d..a5bda53 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -9,12 +9,12 @@ lvresize \(em resize a logical volume
 .IR ProfileName ]
 .RB [ \-i | \-\-stripes " " \fIStripes
 .RB [ \-I | \-\-stripesize " " \fIStripeSize ]]
-.RB {[ \-l | \-\-extents
+.RB { \-l | \-\-extents
 .RI [ + | \- ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN "}] |"
-.RB [ \-L | \-\-size
+.BR \-L | \-\-size
 .RI [ + | \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
 .RB [ \-\-poolmetadatasize
-.RI [ + ] MetadataVolumeSize [ bBsSkKmMgG ]
+.RI [ + ] MetadataVolumeSize [ bBsSkKmMgG ]]
 .RB [ \-f | \-\-force ]
 .RB [ \-n | \-\-nofsck ]
 .RB [ \-r | \-\-resizefs ]


