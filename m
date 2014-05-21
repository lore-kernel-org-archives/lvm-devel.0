From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 May 2014 13:51:35 +0000 (UTC)
Subject: master - man: missing space between option name and value name
Message-ID: <20140521135135.BD1BB6092E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=092659644a6da359272b852d6be058a5fc26bff4
Commit:        092659644a6da359272b852d6be058a5fc26bff4
Parent:        e78092fa3a4cba95ccc8820fb2b2c617e2b0f618
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 21 15:51:28 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed May 21 15:51:28 2014 +0200

man: missing space between option name and value name

---
 man/lvchange.8.in |    2 +-
 man/lvcreate.8.in |    2 +-
 man/lvm.8.in      |    6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 56a35af..09f54e6 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -125,7 +125,7 @@ and copied to the others, so this can take a considerable amount of
 time - and during this time you are without a complete redundant copy
 of your data.
 .TP
-.B \-\-metadataprofile \fIProfileName
+.B \-\-metadataprofile " " \fIProfileName
 Uses and attaches ProfileName configuration profile to the logical
 volume metadata. Whenever the logical volume is processed next time,
 the profile is automatically applied. If the volume group has another
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 78cef80..ee50587 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -284,7 +284,7 @@ will create a persistent log that is itself mirrored.
 When the legacy "mirror" segment type is used, the optional argument
 \fB\-\-corelog\fP is equivalent to \fB\-\-mirrorlog\fP \fIcore\fP.
 .TP
-.BR \-\-metadataprofile \fIProfileName
+.BR \-\-metadataprofile " " \fIProfileName
 Uses and attaches the ProfileName configuration profile to the logical
 volume metadata. Whenever the logical volume is processed next time,
 the profile is automatically applied. If the volume group has another
diff --git a/man/lvm.8.in b/man/lvm.8.in
index c753561..9df3cde 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -281,12 +281,12 @@ an allocation request but \fInormal\fP doesn't use them,
 \fIanywhere\fP will - even if that reduces performance by
 placing two stripes on the same Physical Volume.
 .TP
-.IR \fB\-\-commandprofile \fIProfileName
+.IR \fB\-\-commandprofile " " \fIProfileName
 Selects the command configuration profile to use when processing an LVM command.
 See also \fBlvm.conf\fP(5) for more information about \fBcommand profile config\fP and
 the way it fits with other LVM configuration methods.
 .TP
-.IR \fB\-\-metadataprofile \fIProfileName
+.IR \fB\-\-metadataprofile " " \fIProfileName
 Selects the metadata configuration profile to use when processing an LVM command.
 When using metadata profile during Volume Group or Logical Volume creation,
 the metadata profile name is saved in metadata. When such Volume Group or Logical
@@ -295,7 +295,7 @@ and the use of \-\-metadataprofile option is not necessary. See also
 \fBlvm.conf\fP(5) for more information about \fBmetadata profile config\fP and the
 way it fits with other LVM configuration methods.
 .TP
-.IR \fB\-\-profile \fIProfileName
+.IR \fB\-\-profile " " \fIProfileName
 A short form of \fB\-\-metadataprofile\fP for \fBvgcreate\fP, \fBlvcreate\fP,
 \fBvgchange\fP and \fBlvchange\fP command and a short form of \fB\-\-commandprofile\fP
 for any other command (with the exception of \fBdumpconfig\fP command where the


