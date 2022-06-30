From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:47 +0000 (GMT)
Subject: main - lvmdbusd: Correct grammar in lvm shell proxy comments
Message-ID: <20220630160047.2947F386F0D3@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d393436727014b9eddf71009065f65a59ff3837c
Commit:        d393436727014b9eddf71009065f65a59ff3837c
Parent:        691494268502ddb20da2a14568984c0fa4f29f50
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 6 09:57:20 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: Correct grammar in lvm shell proxy comments

---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index e106ca36f..fa2415fcf 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -123,7 +123,7 @@ class LVMShellProxy(object):
 		tmp_file = "%s/lvmdbus_report" % (tmp_dir)
 
 		try:
-			# Lets create fifo for the report output
+			# Let's create a fifo for the report output
 			os.mkfifo(tmp_file, 0o600)
 		except FileExistsError:
 			pass
@@ -162,7 +162,7 @@ class LVMShellProxy(object):
 		except:
 			raise
 		finally:
-			# These will get deleted when the FD count goes to zero so we
+			# These will get deleted when the FD count goes to zero, so we
 			# can be sure to clean up correctly no matter how we finish
 			os.unlink(tmp_file)
 			os.rmdir(tmp_dir)

