From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 18 Mar 2009 12:18:15 -0400
Subject: [PATCH] Add --config to lvm man page.
Message-ID: <1237393095-4149-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

NOTE: This option is useful in some cases, but in others it is misleading
because it does not really work.  For example, you can try disabling writing
the devices cache via --config 'devices { write_cache_sate = 0 }'.  However,
this does not work since at the bottom of lvm_run_command(), we destroy
the 'cft_override' config tree, and call refresh_toolcontext() again,
resetting the cmd->dump_filter variable which is what we wanted to override.
The writing of the devices cache takes place inside destroy_toolcontext(),
which is called after lvm_run_command() completes.  At this point, the
overridden value has been reset to whatever was in the lvm.conf file
(see _init_filters() code).

Despite some limitations, I felt it was useful to document the option since
we have been verbally telling people they could use this as a workaround
for other issues.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 WHATS_NEW    |    1 +
 man/lvm.8.in |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 20a87a2..f44ecb5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Add --config to lvm man page.
   Detect and conditionally wipe swapspace signatures in pvcreate.
   Fix maximal volume count check for snapshots if max_lv set for volume group.
   Fix lvcreate to remove cow volume if the snapshot creation fails.
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 6bad5fc..eee9bcf 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -153,6 +153,15 @@ than repeated on individual manual pages.
 Repeat from 1 to 3 times to increase the detail of messages 
 sent to stdout and stderr.  Overrides config file setting.
 .TP
+\fB--config\fP \(em Override configuration setting.
+Allows override of \fBlvm.conf\fP (5) config file settings
+for a single command.
+WARNING: Only use this if you know what you are doing!
+Useful in various situations such as using the devices filter
+to limit an lvm command to specific devices.  Example:
+.br
+lvm pvs --config \(aqdevices { filter = ["a/loop[01]/", "r/.*/"] }\(aq
+.TP
 \fB-d | --debug\fP \(em Set debug level.
 Repeat from 1 to 6 times to increase the detail of messages sent 
 to the log file and/or syslog (if configured).
-- 
1.6.0.6


