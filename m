From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:34 +0000 (UTC)
Subject: master - lvmdbusd: Add date & ts if running in a terminal
Message-ID: <20160829202834.3FDB8610E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0a2c84a26a9542d32fa7db1f7dcae8ccb8beb88
Commit:        a0a2c84a26a9542d32fa7db1f7dcae8ccb8beb88
Parent:        7e37e7fde4e683572fa3d9a640821ba9bd4bb3d0
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Aug 12 15:20:49 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:55 2016 -0500

lvmdbusd: Add date & ts if running in a terminal

When we are running in a terminal it's useful to have a date & ts on log
output like you get when output goes to the journal.  Check if we are
running on a tty and if we are, add it in.
---
 daemons/lvmdbusd/utils.py |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 3dcb373..9db7857 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -13,6 +13,7 @@ import inspect
 import ctypes
 import os
 import string
+import datetime
 
 import dbus
 import dbus.service
@@ -243,7 +244,13 @@ def _common_log(msg, *attributes):
 	cfg.stdout_lock.acquire()
 	tid = ctypes.CDLL('libc.so.6').syscall(186)
 
-	msg = "%d:%d - %s" % (os.getpid(), tid, msg)
+	if STDOUT_TTY:
+		msg = "%s: %d:%d - %s" % \
+			(datetime.datetime.now().strftime("%b %d %H:%M:%S.%f"),
+			os.getpid(), tid, msg)
+
+	else:
+		msg = "%d:%d - %s" % (os.getpid(), tid, msg)
 
 	if STDOUT_TTY and attributes:
 		print(color(msg, *attributes))


