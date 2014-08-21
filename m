From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 21 Aug 2014 08:28:17 +0000 (UTC)
Subject: master - man: dmsetup: -n is shortcut for --notable, not --noheadings
Message-ID: <20140821082817.DE907610DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e208d65043118907ff657c30f1423e96911fbbe
Commit:        7e208d65043118907ff657c30f1423e96911fbbe
Parent:        473a4a65485d881edfb2220a2e8f3d4fbf228818
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 21 10:26:16 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 21 10:26:16 2014 +0200

man: dmsetup: -n is shortcut for --notable, not --noheadings

The -n was defined for --notable since beginning, but the man page
got wrong at some time...
---
 man/dmsetup.8.in |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 477e425..e2a1a5c 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -10,7 +10,7 @@ dmsetup \(em low level logical volume management
 .I device_name
 .RB [ \-u
 .IR uuid ]
-.RB [ \-\-notable | \-\-table
+.RB [ \-n | \-\-notable | \-\-table
 .RI < table >|
 .RS
 .IR table_file ]
@@ -219,15 +219,15 @@ Specify the major number.
 .BR \-m | \-\-minor\ \fIminor
 Specify the minor number.
 .TP
-.BR \-n | \-\-noheadings
+.BR \-n | \-\-notable
+When creating a device, don't load any table.
+.TP
+.BR \-\-noheadings
 Suppress the headings line when using columnar output.
 .TP
 .B \-\-noopencount
 Tell the kernel not to supply the open reference count for the device.
 .TP
-.B \-\-notable
-When creating a device, don't load any table.
-.TP
 .B \-\-noudevrules
 Do not allow udev to manage nodes for devices in device-mapper directory.
 .TP
@@ -295,7 +295,7 @@ Destroys the table in the inactive table slot for device_name.
 .I device_name
 .RB [ \-u
 .IR uuid ]
-.RB [ \-\-notable | \-\-table
+.RB [ \-n | \-\-notable | \-\-table
 .RI < \fItable >| table_file ]
 .RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
 .RB [ \-\-readahead


