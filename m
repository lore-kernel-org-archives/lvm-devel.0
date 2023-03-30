From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Mar 2023 16:05:15 +0000 (GMT)
Subject: main - lvmdbusd: Correct locking for _common_log
Message-ID: <20230330160515.32D253858CDA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7ca470abe995210e8008084c0b4436292b2816b
Commit:        f7ca470abe995210e8008084c0b4436292b2816b
Parent:        d6f8f59239c65a7f1f9be1d24bf9ba02cfee5b0e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 30 10:07:13 2023 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 30 11:04:42 2023 -0500

lvmdbusd: Correct locking for _common_log

Reduce the lock time and include the flush in the lock.

Reported by: Zbigniew J??drzejewski-Szmek <zbyszek@in.waw.pl>
---
 daemons/lvmdbusd/utils.py | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 6013b656f..fdd7578c1 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -323,16 +323,17 @@ def _format_log_entry(msg):
 
 
 def _common_log(msg, *attributes):
-	cfg.stdout_lock.acquire()
 	msg = _format_log_entry(msg)
 
+	cfg.stdout_lock.acquire()
+
 	if STDOUT_TTY and attributes:
 		print(color(msg, *attributes))
 	else:
 		print(msg)
 
-	cfg.stdout_lock.release()
 	sys.stdout.flush()
+	cfg.stdout_lock.release()
 
 
 # Serializes access to stdout to prevent interleaved output

