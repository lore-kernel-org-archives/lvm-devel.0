From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:38 +0000 (GMT)
Subject: main - lvmdbusd: Simplify child process env
Message-ID: <20220630160038.170F53842AF1@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=58c6c9e9aa8d6aa6d3be14a04ec0f4257b61495e
Commit:        58c6c9e9aa8d6aa6d3be14a04ec0f4257b61495e
Parent:        37733cd4eb5116db371ac1ae6e971e3c336c3ddb
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed May 25 15:52:20 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: Simplify child process env

We don't need to duplicate the entire env from the parent, supply only what
is needed.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 78fe1e422..10719c67e 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -135,7 +135,8 @@ class LVMShellProxy(object):
 		self.report_stream = os.fdopen(self.report_fd, 'rb', 0)
 
 		# Setup the environment for using our own socket for reporting
-		local_env = copy.deepcopy(os.environ)
+		local_env = {}
+		local_env["LC_ALL"] = "C"
 		local_env["LVM_REPORT_FD"] = "32"
 		local_env["LVM_COMMAND_PROFILE"] = "lvmdbusd"
 

