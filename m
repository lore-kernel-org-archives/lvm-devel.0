From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 19 Feb 2017 23:46:56 +0000 (UTC)
Subject: master - man: dmsetup update
Message-ID: <20170219234656.49FB760563@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=665479b818a7e43ca8176fcfdbe34f0fad03451e
Commit:        665479b818a7e43ca8176fcfdbe34f0fad03451e
Parent:        2a21a19d904c34e56e3ab3fe026dbc5658f68925
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 19 15:50:49 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 19 22:59:43 2017 +0100

man: dmsetup update

---
 man/dmsetup.8.in |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 36a6d74..bd26efa 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -27,9 +27,9 @@ dmsetup \(em low level logical volume management
 .  IR uuid ]
 .  RB \%[ \-\-addnodeoncreate | \-\-addnodeonresume ]
 .  RB \%[ \-n | \-\-notable | \-\-table
-.  RI \%{ table | table_file }]
+.  IR \%table | table_file ]
 .  RB [ \-\-readahead
-.  RB \%{[ + ] \fIsectors | auto | none }]
+.  RB \%[ + ] \fIsectors | auto | none ]
 .  ad b
 ..
 .CMD_CREATE
@@ -92,7 +92,7 @@ dmsetup \(em low level logical volume management
 .  BR load
 .  IR device_name
 .  RB [ \-\-table
-.  RI { table | table_file }]
+.  IR table | table_file ]
 .  ad b
 ..
 .CMD_LOAD
@@ -146,7 +146,7 @@ dmsetup \(em low level logical volume management
 .  BR reload
 .  IR device_name
 .  RB [ \-\-table
-.  RI { table | table_file }]
+.  IR table | table_file ]
 .  ad b
 ..
 .CMD_RELOAD
@@ -202,7 +202,7 @@ dmsetup \(em low level logical volume management
 .  RB [ \-\-noflush ]
 .  RB [ \-\-nolockfs ]
 .  RB \%[ \-\-readahead
-.  RB \%{[ + ] \fIsectors | auto | none }]
+.  RB \%[ + ] \fIsectors | auto | none ]
 .  ad b
 ..
 .CMD_RESUME
@@ -447,7 +447,7 @@ The default interval is one second.
 .
 .HP
 .BR \-\-manglename
-.RB { auto | hex | none }
+.BR auto | hex | none
 .br
 Mangle any character not on a whitelist using mangling_mode when
 processing device-mapper device names and UUIDs. The names and UUIDs
@@ -529,7 +529,7 @@ Specify which fields to display.
 .
 .HP
 .BR \-\-readahead
-.RB {[ + ] \fIsectors | auto | none }
+.RB [ + ] \fIsectors | auto | none
 .br
 Specify read ahead size in units of sectors.
 The default value is \fBauto\fP which allows the kernel to choose


