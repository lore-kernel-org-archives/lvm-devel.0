From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Mar 2009 11:45:29 -0500
Subject: [PATCH] Add --config to lvm man page.
Message-ID: <1236012329-5499-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/lvm.8.in |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 6bad5fc..1b93b5e 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -153,6 +153,13 @@ than repeated on individual manual pages.
 Repeat from 1 to 3 times to increase the detail of messages 
 sent to stdout and stderr.  Overrides config file setting.
 .TP
+\fB--config\fP \(em Override configuration setting.
+Allows override of \fBlvm.conf\fP (5) config file settings.
+Useful in various situations such as using the devices filter
+to limit an lvm command to specific devices.  Example:
+.br
+lvm pvs --config 'devices { filter = ["a/loop[01]/", "r/.*/"] }'
+.TP
 \fB-d | --debug\fP \(em Set debug level.
 Repeat from 1 to 6 times to increase the detail of messages sent 
 to the log file and/or syslog (if configured).
-- 
1.6.0.6


