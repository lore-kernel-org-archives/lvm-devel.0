From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Mar 2016 09:20:08 +0000 (UTC)
Subject: master - man: minor updates
Message-ID: <20160303092008.93875605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25bf0beedb8042ed77d97a79289168255b451475
Commit:        25bf0beedb8042ed77d97a79289168255b451475
Parent:        fd349cb2e50ff60abb5c79d2aab60cc753faa174
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 2 23:51:59 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 3 10:17:03 2016 +0100

man: minor updates

Minor fixes in few pages.
---
 man/lvchange.8.in    |    2 +-
 man/vgcfgbackup.8.in |    7 ++++---
 man/vgchange.8.in    |    2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 8ae17a0..fb16530 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -410,7 +410,7 @@ If \fB\-\-sysinit\fP is used in conjunction with
 \fBlvmetad\fP(8) enabled and running,
 autoactivation is preferred over manual activation via direct lvchange call.
 Logical volumes are autoactivated according to
-\fB auto_activation_volume_list\fP set in \fBlvm.conf\fP(5).
+\fBauto_activation_volume_list\fP set in \fBlvm.conf\fP(5).
 .
 .HP
 .BR \-Z | \-\-zero
diff --git a/man/vgcfgbackup.8.in b/man/vgcfgbackup.8.in
index 17b3bcb..898764a 100644
--- a/man/vgcfgbackup.8.in
+++ b/man/vgcfgbackup.8.in
@@ -7,7 +7,7 @@ vgcfgbackup \(em backup volume group descriptor area
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-f | \-\-file
-.RI < filename >]
+.IR Filename ]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-P | \-\-partial ]
@@ -19,13 +19,14 @@ If you don't name any volume groups on the command line, all of them
 will be backed up.
 .sp
 In a default installation, each volume group gets backed up into a separate
-file bearing the name of the volume group in the directory #DEFAULT_BACKUP_DIR#.
+file bearing the name of the volume group in the directory
+\fI#DEFAULT_BACKUP_DIR#\fP.
 You can write the backup to an alternative file using \fB\-f\fP.  In this case
 if you are backing up more than one volume group the filename is
 treated as a template, and %s gets replaced by the volume group name.
 .sp
 NB. This DOESN'T backup user/system data in logical
-volume(s)!  Backup #DEFAULT_SYS_DIR# regularly too.
+volume(s)!  Backup \fI#DEFAULT_SYS_DIR#\fP regularly too.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .SH SEE ALSO
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 77ab70e..fd7ee9d 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -13,7 +13,7 @@ vgchange \(em change attributes of a volume group
 .RI [ a | e | s | l ]
 .RI { y | n }]
 .RB [ \-\-activationmode
-.IR { complete | degraded | partial } ]
+.IB { complete | degraded | partial } ]
 .RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-monitor
 .RI { y | n }]


