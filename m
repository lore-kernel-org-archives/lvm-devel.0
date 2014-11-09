From: saulery@free.fr <saulery@free.fr>
Date: Sun,  9 Nov 2014 02:18:31 +0100
Subject: man: fix (\+) syntax warning of Groff
In-Reply-To: <1415495911-2787-1-git-send-email-saulery@free.fr>
References: <1415495911-2787-1-git-send-email-saulery@free.fr>
Message-ID: <1415495911-2787-2-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 man/dmsetup.8.in | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

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
-- 
2.1.1


