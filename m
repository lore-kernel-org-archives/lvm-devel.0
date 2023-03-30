From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Mar 2023 16:05:16 +0000 (GMT)
Subject: main - lvmdbusd: Correct seg. fault on s390x ELN
Message-ID: <20230330160516.560ED3858CDB@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=300c8209a810f287992376e8a0561fdf878d1520
Commit:        300c8209a810f287992376e8a0561fdf878d1520
Parent:        f7ca470abe995210e8008084c0b4436292b2816b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 30 10:10:23 2023 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 30 11:04:49 2023 -0500

lvmdbusd: Correct seg. fault on s390x ELN

syscall 186 is specific to x86 64bit.  As this is different from arch
to arch and between same arch different arch size we will only grab
thread ID using built-in python support if it is supported.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=2166931
---
 daemons/lvmdbusd/utils.py | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index fdd7578c1..27b869c13 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -11,7 +11,6 @@ import xml.etree.ElementTree as Et
 import sys
 import inspect
 import collections
-import ctypes
 import errno
 import fcntl
 import os
@@ -305,8 +304,16 @@ class DebugMessages(object):
 					self.queue.clear()
 
 
+def _get_tid():
+	try:
+		# Only 3.8 and later have this
+		return threading.get_native_id()
+	except:
+		return -1
+
+
 def _format_log_entry(msg):
-	tid = ctypes.CDLL('libc.so.6').syscall(186)
+	tid = _get_tid()
 
 	if not cfg.systemd and STDOUT_TTY:
 		msg = "%s: %d:%d - %s" % \

