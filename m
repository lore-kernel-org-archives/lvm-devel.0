From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Nov 2014 08:40:56 +0000 (UTC)
Subject: master - man: fix (\+) syntax warning of Groff
Message-ID: <20141112084056.AF62660C45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=112302d41a2cbf0c28c5cb65774121302ba374be
Commit:        112302d41a2cbf0c28c5cb65774121302ba374be
Parent:        eccc97f15a0f2e19f5ccc714cb4880644b4772df
Author:        St??phane Aulery <saulery@free.fr>
AuthorDate:    Sun Nov 9 02:18:31 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 12 09:39:19 2014 +0100

man: fix (\+) syntax warning of Groff

Signed-off-by: St??phane Aulery <saulery@free.fr>
---
 WHATS_NEW_DM     |    1 +
 man/dmsetup.8.in |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6f23958..a89696f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.92 - 
 ====================================
+  Fix man dmsetup.8 syntax warning of Groff
 
 Version 1.02.91 - 11th November 2014
 ====================================
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index e2a1a5c..57fbdf9 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -16,7 +16,7 @@ dmsetup \(em low level logical volume management
 .IR table_file ]
 .RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
 .RB [ \-\-readahead
-.RI [ \+ ]< sectors >| auto | none ]
+.RI [ + ]< sectors >| auto | none ]
 .RE
 .br
 .B dmsetup deps
@@ -101,7 +101,7 @@ dmsetup \(em low level logical volume management
 .RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
 .RS
 .RB [ \-\-readahead
-.RI [ \+ ]< sectors >| auto | none ]
+.RI [ + ]< sectors >| auto | none ]
 .RE
 .br
 .B dmsetup setgeometry
@@ -237,10 +237,10 @@ Do not synchronise with udev when creating, renaming or removing devices.
 .BR \-o | \-\-options
 Specify which fields to display.
 .TP
-.IR \fB\-\-readahead \ [ \+ ]< sectors >| auto | none
+.IR \fB\-\-readahead \ [ + ]< sectors >| auto | none
 Specify read ahead size in units of sectors.
 The default value is \fIauto\fP which allows the kernel to choose
-a suitable value automatically.  The \fI\+\fP prefix lets you
+a suitable value automatically.  The \fI+\fP prefix lets you
 specify a minimum value which will not be used if it is
 smaller than the value chosen by the kernel.
 The value \fInone\fP is equivalent to specifying zero.


