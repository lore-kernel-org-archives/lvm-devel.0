From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:42 +0000 (GMT)
Subject: main - lvmdbusd: Correct log_error for shell proxy
Message-ID: <20220919155842.3660C3858298@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c5762038a7d2877dca91593ca212e0e36802dc1
Commit:        2c5762038a7d2877dca91593ca212e0e36802dc1
Parent:        d51fb57f1abf9e24aa8c74df5ffd717e2d45c103
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 8 15:40:03 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Correct log_error for shell proxy

---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index fb6ce6164..244fe93f5 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -297,7 +297,7 @@ if __name__ == "__main__":
 			except EOFError:
 				pass
 	except Exception as e:
-		log_error("main process exiting on exception!\n%s", extract_stack_trace(e))
+		log_error("main process exiting on exception!\n%s" % extract_stack_trace(e))
 		sys.exit(1)
 
 	sys.exit(0)

