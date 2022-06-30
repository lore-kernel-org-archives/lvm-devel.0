From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:52 +0000 (GMT)
Subject: main - lvmdbusd: Remove try/except for mkfifo
Message-ID: <20220630160052.C92D0386F0E0@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=01ef2f2525e8733f01443987b2c6f99882e04f3d
Commit:        01ef2f2525e8733f01443987b2c6f99882e04f3d
Parent:        0d957dcacc3118e9f2d4e83830d6c93b8955fd5f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 7 08:21:03 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: Remove try/except for mkfifo

We should never run into this error condition when using tempfile.mkdtemp.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index fa2415fcf..5802d2d70 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -122,11 +122,8 @@ class LVMShellProxy(object):
 		tmp_dir = tempfile.mkdtemp(prefix="lvmdbus_")
 		tmp_file = "%s/lvmdbus_report" % (tmp_dir)
 
-		try:
-			# Let's create a fifo for the report output
-			os.mkfifo(tmp_file, 0o600)
-		except FileExistsError:
-			pass
+		# Create a fifo for the report output
+		os.mkfifo(tmp_file, 0o600)
 
 		# Open the fifo for use to read and for lvm child process to write to.
 		self.report_fd = os.open(tmp_file, os.O_NONBLOCK)

