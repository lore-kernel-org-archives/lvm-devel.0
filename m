From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:38 +0000 (UTC)
Subject: dev-dct-process-latest - man: document obsoleted options
Message-ID: <20140922153938.564CA6092E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=081e406d0d0c02d8fb6f93d6b8fb97f4217fde62
Commit:        081e406d0d0c02d8fb6f93d6b8fb97f4217fde62
Parent:        e3cbdde070b25db30984efa0898f16c2555301d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 14:53:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 15:55:47 2014 +0200

man: document obsoleted options

It's shown on comand line help and it's accepted argument,
so provide matching man entry.
---
 man/lvchange.8.in |    9 ++++++++-
 man/lvcreate.8.in |    9 ++++++++-
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 39187f0..d3d63fd 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -50,9 +50,11 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-\-metadataprofile
 .IR ProfileName ]
 .RB [ \-M | \-\-persistent
-.RI { y | n }]
+.RI { y | n }
 .RB [ \-\-minor
 .IR minor ]
+.RB [ \-\-major
+.IR major ]]
 .RB [ \-P | \-\-partial ]
 .RB [ \-p | \-\-permission
 .RI { r | rw }]
@@ -165,6 +167,11 @@ See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
 .B \-\-minor \fIminor
 Set the minor number.
 .TP
+.B \-\-major \fImajor
+Sets the major number. This option is supported only on older systems
+(kernel version 2.4) and is ignored on modern Linux systems where major
+numbers are dynamically assigned.
+.TP
 .BR \-\-monitor " {" \fIy | \fIn }
 Start or stop monitoring a mirrored or snapshot logical volume with
 dmeventd, if it is installed.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 5440ced..ed0ed65 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -43,9 +43,11 @@ lvcreate \- create a logical volume in an existing volume group
 .BR \-V | \-\-virtualsize
 .IR VirtualSize [ bBsSkKmMgGtTpPeE ]}
 .RB [ \-M | \-\-persistent
-.RI { y | n }]
+.RI { y | n }
 .RB [ \-\-minor
 .IR minor ]
+.RB [ \-\-major
+.IR major ]]
 .RB [ \-m | \-\-mirrors
 .IR Mirrors
 .RB [ \-\-nosync ]
@@ -298,6 +300,11 @@ Set to \fIy\fP to make the minor number specified persistent.
 .B \-\-minor \fIminor
 Sets the minor number.
 .TP
+.B \-\-major \fImajor
+Sets the major number. This option is supported only on older systems
+(kernel version 2.4) and is ignored on modern Linux systems where major
+numbers are dynamically assigned.
+.TP
 .BR \-\-monitor " {" \fIy | \fIn }
 Starts or avoids monitoring a mirrored, snapshot or thin pool logical volume with
 dmeventd, if it is installed.


