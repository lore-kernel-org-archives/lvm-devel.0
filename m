From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 24 Jun 2015 19:44:41 +0000 (UTC)
Subject: master - man: Add missing env vars to lvm man page.
Message-ID: <20150624194441.74CD561150@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=110a0745cd162680002c8f7d30220dd627300a95
Commit:        110a0745cd162680002c8f7d30220dd627300a95
Parent:        7760665fb8f4a85a244a9751a0a1d1cc46c157dc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jun 24 20:43:35 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jun 24 20:43:35 2015 +0100

man: Add missing env vars to lvm man page.

---
 WHATS_NEW    |    1 +
 man/lvm.8.in |   35 +++++++++++++++++++++++++++++------
 2 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 34f4cf0..41e5cc4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.123 - 
 =================================
+  Add undocumented environment variables to lvm man page. (2.02.119)
   Add device synchronization point before activating a new snapshot.
   Add --withspaces to lvmconfig to add spaces in output for better readability.
 
diff --git a/man/lvm.8.in b/man/lvm.8.in
index b8b4854..685a4fc 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -518,8 +518,7 @@ Directory containing \fBlvm.conf\fP(5) and other LVM system files.
 Defaults to "#DEFAULT_SYS_DIR#".
 .TP
 .B LVM_SUPPRESS_FD_WARNINGS
-Suppress warnings about openned file descriptors, when lvm command
-is executed.
+Suppress warnings about unexpected file descriptors passed into LVM.
 .TP
 .B LVM_VG_NAME
 The Volume Group name that is assumed for
@@ -527,16 +526,40 @@ any reference to a Logical Volume that doesn't specify a path.
 Not set by default.
 .TP
 .B LVM_LVMETAD_PIDFILE
-Path for the lvmetad pid file.
+Path to the file that stores the lvmetad process ID.
 .TP
 .B LVM_LVMETAD_SOCKET
-Path for the lvmetad socket file.
+Path to the socket used to communicate with lvmetad.
 .TP
 .B LVM_LVMPOLLD_PIDFILE
-Path for the lvmpolld pid file.
+Path to the file that stores the lvmpolld process ID.
 .TP
 .B LVM_LVMPOLLD_SOCKET
-Path for the lvmpolld socket file.
+Path to the socket used to communicate with lvmpolld..
+.TP
+.B LVM_LOG_FILE_EPOCH
+A string of up to 32 letters appended to the log filename and
+followed by the process ID and a timestamp.  When set, each process logs to a
+separate file.
+.TP
+.B LVM_EXPECTED_EXIT_STATUS
+The status anticipated when the process exits.  Use ">N" to match any
+status greater than N.  If the actual exit status matches and a log
+file got produced, it is deleted.
+
+LVM_LOG_FILE_EPOCH and LVM_EXPECTED_EXIT_STATUS together allow
+automated test scripts to discard uninteresting log data.
+.TP
+.B LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES
+Used to suppress warning messages when the configured locking is known
+to be unavailable.
+.TP
+.B DM_ABORT_ON_INTERNAL_ERRORS
+Abort processing if the code detects a non-fatal internal error.
+.TP
+.B DM_DISABLE_UDEV
+Avoid interaction with udev.  LVM will manage the relevant nodes in /dev
+directly.
 .SH FILES
 .I #DEFAULT_SYS_DIR#/lvm.conf
 .br


