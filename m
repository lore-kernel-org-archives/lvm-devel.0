From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 19 Feb 2017 23:47:00 +0000 (UTC)
Subject: master - man: thin dmeventd plugin update
Message-ID: <20170219234700.655AC60563@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f16ad760cb828228affd13cb6d701dfb54a5f249
Commit:        f16ad760cb828228affd13cb6d701dfb54a5f249
Parent:        cd24e6de898f9f20a56430d4a6d55c635a65bc65
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 19 15:50:19 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 20 00:43:12 2017 +0100

man: thin dmeventd plugin update

Document new dmeventd/thin_command lvm.conf configurable.
---
 man/dmeventd.8.in |  108 ++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 74 insertions(+), 34 deletions(-)

diff --git a/man/dmeventd.8.in b/man/dmeventd.8.in
index aa62451..057f756 100644
--- a/man/dmeventd.8.in
+++ b/man/dmeventd.8.in
@@ -23,40 +23,6 @@ dmeventd is the event monitoring daemon for device-mapper devices.
 Library plugins can register and carry out actions triggered when
 particular events occur.
 .
-.SH LVM PLUGINS
-.
-.HP
-.IR Mirror
-.br
-Attempts to handle device failure automatically. See
-.BR lvm.conf (5).
-.
-.HP
-.IR Raid
-.br
-Attempts to handle device failure automatically. See
-.BR lvm.conf (5).
-.
-.HP
-.IR Snapshot
-.br
-Monitors how full a snapshot is becoming and emits a warning to
-syslog when it exceeds 80% full.
-The warning is repeated when 85%, 90% and 95% of the snapshot is filled.
-See
-.BR lvm.conf (5).
-Snapshot which runs out of space gets invalid and when it is mounted,
-it gets umounted if possible.
-.
-.HP
-.IR Thin
-.br
-Monitors how full a thin pool data and metadata is becoming and emits
-a warning to syslog when it exceeds 80% full.
-The warning is repeated when 85%, 90% and 95% of the thin pool is filled.
-See
-.BR lvm.conf (5).
-If the thin-pool runs out of space, thin volumes are umounted if possible.
 .
 .SH OPTIONS
 .
@@ -104,6 +70,80 @@ events to monitor from the currently running daemon.
 .br
 Show version of dmeventd.
 .
+.SH LVM PLUGINS
+.
+.HP
+.BR Mirror
+.br
+Attempts to handle device failure automatically. See
+.BR lvm.conf (5).
+.
+.HP
+.BR Raid
+.br
+Attempts to handle device failure automatically. See
+.BR lvm.conf (5).
+.
+.HP
+.BR Snapshot
+.br
+Monitors how full a snapshot is becoming and emits a warning to
+syslog when it exceeds 80% full.
+The warning is repeated when 85%, 90% and 95% of the snapshot is filled.
+See
+.BR lvm.conf (5).
+Snapshot which runs out of space gets invalid and when it is mounted,
+it gets umounted if possible.
+.
+.HP
+.BR Thin
+.br
+Monitors how full a thin pool data and metadata is becoming and emits
+a warning to syslog when it exceeds 80% full.
+The warning is repeated when more then 85%, 90% and 95%
+of the thin pool is filled. See
+.BR lvm.conf (5).
+When a thin pool fills over 50% (data or metadata) thin plugin calls
+configured \fIdmeventd/thin_command\fP with every 5% increase.
+With default setting it calls internal
+\fBlvm lvextend --use-policies\fP to resize thin pool
+when it's been filled above configured threshold
+\fIactivation/thin_pool_autoextend_threshold\fP.
+If the command fails, dmeventd thin plugin will keep
+retrying execution with increasing time delay between
+retries upto 42 minutes.
+User may also configure external command to support more advanced
+maintenance operations of a thin pool.
+Such external command can e.g. remove some unneeded snapshots,
+use \fBfstrim\fP(8) to free recover space in a thin pool,
+but also can use \fBlvextend --use-policies\fP if other actions
+have not released enough space.
+Command is executed with environmental variable
+\fBLVM_RUN_BY_DMEVENTD=1\fP so any lvm2 command executed
+in this environment will not try to interact with dmeventd.
+To see the fullness of a thin pool command may check these
+two environmental variables
+\fBDMEVENTD_THIN_POOL_DATA\fP and \fBDMEVENTD_THIN_POOL_DATA\fP.
+Command can also read status with tools like \fBlvs\fP(8).
+.
+.SH ENVIRONMENT VARIABLES
+.
+.TP
+.B DMEVENTD_THIN_POOL_DATA
+Variable is set by thin plugin and is available to executed program. Value present
+actual usage of thin pool data volume. Variable is not set when error event
+is processed.
+.TP
+.B DMEVENTD_THIN_POOL_DATA
+Variable is set by thin plugin and is available to executed program. Value present
+actual usage of thin pool metadata volume. Variable is not set when error event
+is processed.
+.TP
+.B LVM_RUN_BY_DMEVENTD
+Variable is set by thin plugin to prohibit recursive interation
+with dmeventd by any executed lvm2 command from
+a thin_command environment.
+.
 .SH SEE ALSO
 .
 .BR lvm (8),


