From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:40:13 -0400
Subject: master - man: dmeventd vdo plugin
Message-ID: <201903201340.x2KDeDdV012623@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1117f1d46f9cbc4a0a29a975ab5c5588d63a2feb
Commit:        1117f1d46f9cbc4a0a29a975ab5c5588d63a2feb
Parent:        597113646d10e14044e0b89712342ae73b77b697
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 23 22:51:00 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:39:11 2019 +0100

man: dmeventd vdo plugin

---
 man/dmeventd.8_main |   39 +++++++++++++++++++++++++++++++++++++--
 1 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/man/dmeventd.8_main b/man/dmeventd.8_main
index 06f8f58..dc4abf6 100644
--- a/man/dmeventd.8_main
+++ b/man/dmeventd.8_main
@@ -125,6 +125,36 @@ To see the fullness of a thin pool command may check these
 two environmental variables
 \fBDMEVENTD_THIN_POOL_DATA\fP and \fBDMEVENTD_THIN_POOL_METADATA\fP.
 Command can also read status with tools like \fBlvs\fP(8).
+
+.HP
+.BR Vdo
+.br
+Monitors how full a VDO pool data is becoming and emits
+a warning to syslog when it exceeds 80% full.
+The warning is repeated when more then 85%, 90% and 95%
+of the VDO pool is filled. See
+.BR lvm.conf (5).
+When a VDO pool fills over 50% vdo plugin calls
+configured \fIdmeventd/vdo_command\fP with every 5% increase.
+With default setting it calls internal
+\fBlvm lvextend --use-policies\fP to resize VDO pool
+when it's been filled above the configured threshold
+\fIactivation/vdo_pool_autoextend_threshold\fP.
+If the command fails, dmeventd vdo plugin will keep
+retrying execution with increasing time delay between
+retries upto 42 minutes.
+User may also configure external command to support more advanced
+maintenance operations of a VDO pool.
+Such external command can e.g. remove some unneeded space
+with \fBfstrim\fP(8),
+but also can use \fBlvextend --use-policies\fP if other actions
+have not released enough space.
+Command is executed with environmental variable
+\fBLVM_RUN_BY_DMEVENTD=1\fP so any lvm2 command executed
+in this environment will not try to interact with dmeventd.
+To see the fullness of a VDO pool command may check this
+environmental variable \fBDMEVENTD_VDO_POOL\fP.
+Command can also read status with tools like \fBlvs\fP(8).
 .
 .SH ENVIRONMENT VARIABLES
 .
@@ -139,10 +169,15 @@ Variable is set by thin plugin and is available to executed program. Value prese
 actual usage of thin pool metadata volume. Variable is not set when error event
 is processed.
 .TP
+.B DMEVENTD_VDO_POOL
+Variable is set by vdo plugin and is available to executed program. Value present
+actual usage of VDO pool data volume. Variable is not set when error event
+is processed.
+.TP
 .B LVM_RUN_BY_DMEVENTD
-Variable is set by thin plugin to prohibit recursive interation
+Variable is set by thin and vdo plugin to prohibit recursive interation
 with dmeventd by any executed lvm2 command from
-a thin_command environment.
+a thin_command, vdo_command environment.
 .
 .SH SEE ALSO
 .


