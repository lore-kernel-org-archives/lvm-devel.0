From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Jun 2014 09:11:38 +0000 (UTC)
Subject: master - man: more compliant
Message-ID: <20140611091138.B706F60F96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1568376360b3e0b0d640441909bc92056009143
Commit:        e1568376360b3e0b0d640441909bc92056009143
Parent:        08969876330111e6d49618ff0313bdd61b69d7f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 10 19:32:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 11 11:10:55 2014 +0200

man: more compliant

---
 man/blkdeactivate.8.in |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/man/blkdeactivate.8.in b/man/blkdeactivate.8.in
index 9998744..bfd0204 100644
--- a/man/blkdeactivate.8.in
+++ b/man/blkdeactivate.8.in
@@ -15,31 +15,41 @@ LVM volumes are handled directly using the \fIlvm\fP command.
 Other device-mapper based devices are handled using the
 \fIdmsetup\fP command.
 .SH OPTIONS
-.IP "\fB\-e, \-\-errors\fP"
+.TP
+.BR \-e ", " \-\-errors
 Show errors reported from tools called by blkdeactivate.
 Without this option, any error messages from these external tools
 are suppressed and the blkdeactivate itself provides only a summary
 message about device being skipped or not.
-.IP "\fB\-h, \-\-help\fP"
+.TP
+.BR \-h ", " \-\-help
 Display the help text.
-.IP "\fB\-u, \-\-umount\fP"
+.TP
+.BR \-u ", " \-\-umount
 Unmount a mounted device before trying to deactivate it.
 Without this option used, a device that is mounted is not deactivated.
-.IP "\fB\-v, \-\-verbose\fP"
+.TP
+.BR \-v ", " \-\-verbose
 Run in verbose mode.
-.IP "\fB\-d, \-\-dmoption\fP \fIdm_options\fP"
+.TP
+.BR \-d ", " \-\-dmoption " " \fIdm_options
 Comma separated list of device-mapper specific options.
-.IP "\fB\-l, \-\-lvmoption\fP \fIlvm_options\fP"
+.TP
+.BR \-l ", " \-\-lvmoption " " \fIlvm_options
 Comma separated list of LVM specific options.
 .SH DM_OPTIONS
-.IP "\fBretry\fP"
+.TP
+.B retry
 Retry removal several times in case of failure.
-.IP "\fBforce\fP"
+.TP
+.B force
 Force device removal. See \fBdmsetup\fP(8) for more information.
 .SH LVM_OPTIONS
-.IP "\fBretry\fP"
+.TP
+.B retry
 Retry removal several times in case of failure.
-.IP "\fBwholevg\fP"
+.TP
+.B wholevg
 Deactivate the whole LVM Volume Group when processing a Logical Volume.
 Deactivating Volume Group as a whole takes less time than deactivating
 each Logical Volume separately.


