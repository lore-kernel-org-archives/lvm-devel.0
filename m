From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  4 Aug 2015 12:04:04 +0000 (UTC)
Subject: master - man: document --nameprefixes
Message-ID: <20150804120404.3AC3660553@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce1528359a3021e255fec59962f21b18d6bb027a
Commit:        ce1528359a3021e255fec59962f21b18d6bb027a
Parent:        f02cdcff0084a323c9651d7ca2f22d60c83bcf3d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 4 14:03:50 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 4 14:03:50 2015 +0200

man: document --nameprefixes

---
 man/dmsetup.8.in |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 14e393a..ded7ca1 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -32,6 +32,7 @@ dmsetup \(em low level logical volume management
 .br
 .B dmsetup info
 .BR \-c | \-C | \-\-columns
+.RB [ \-\-nameprefixes ]
 .RB [ \-\-noheadings ]
 .RB [ \-\-separator
 .IR separator ]
@@ -236,6 +237,10 @@ Specify the minor number.
 .BR \-n | \-\-notable
 When creating a device, don't load any table.
 .TP
+.BR \-\-nameprefixes
+Add a "DM_" prefix plus the field name to the output.  Useful with --noheadings to produce a list of
+field=value pairs that can be used to set environment variables (for example, in udev(7) rules).
+.TP
 .BR \-\-noheadings
 Suppress the headings line when using columnar output.
 .TP


