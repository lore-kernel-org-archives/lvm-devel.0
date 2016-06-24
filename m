From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 24 Jun 2016 12:57:32 +0000 (UTC)
Subject: master - man: lvs: move doc about --all so it's ordered alphabetically in the man page
Message-ID: <20160624125732.518FC60DBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d914151591dab4ac924fe3b72fb296bc66f2e51c
Commit:        d914151591dab4ac924fe3b72fb296bc66f2e51c
Parent:        a910052a2e7da4531ff0e39e569ab2eaa56b1870
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 24 14:56:43 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 24 14:57:09 2016 +0200

man: lvs: move doc about --all so it's ordered alphabetically in the man page

---
 man/lvs.8.in |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/man/lvs.8.in b/man/lvs.8.in
index 7bd25a6..3cb2d2b 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -53,6 +53,16 @@ for common options.
 .B \-\-aligned
 Use with \fB\-\-separator\fP to align the output columns.
 .TP
+.B \-\-all
+Include information in the output about internal Logical Volumes that
+are components of normally-accessible Logical Volumes, such as mirrors,
+but which are not independently accessible (e.g. not mountable).
+The names of such Logical Volumes are enclosed within square brackets
+in the output.  For example, after creating a mirror using
+.B lvcreate -m1 \-\-mirrorlog disk
+, this option will reveal three internal Logical
+Volumes, with suffixes mimage_0, mimage_1, and mlog.
+.TP
 .B \-\-binary
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
@@ -67,16 +77,6 @@ command's main report is assumed. The log report is available only if
 enabled by \fBlog/report_command_log\fP \fBlvm.conf\fP(5) setting or
 if \fB\-\-logonly\fP option is used.
 .TP
-.B \-\-all
-Include information in the output about internal Logical Volumes that
-are components of normally-accessible Logical Volumes, such as mirrors,
-but which are not independently accessible (e.g. not mountable).
-The names of such Logical Volumes are enclosed within square brackets
-in the output.  For example, after creating a mirror using
-.B lvcreate -m1 \-\-mirrorlog disk
-, this option will reveal three internal Logical
-Volumes, with suffixes mimage_0, mimage_1, and mlog.
-.TP
 .B \-H ", " \-\-history
 Include historical logical volumes in the output.
 (This has no effect unless logical volumes were removed while the configuration


