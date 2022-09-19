From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:35 +0000 (GMT)
Subject: main - lvmdbusd: Handle 'exit' for lvm_shell_proxy
Message-ID: <20220919155835.615293858292@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9fc24b1d3b205af1b2e3c4799c575e72a8640842
Commit:        9fc24b1d3b205af1b2e3c4799c575e72a8640842
Parent:        b3d13c50d7adb838675929968317f9e42a2f485f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Sep 6 16:24:20 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Handle 'exit' for lvm_shell_proxy

Useful for testing `exit_shell` when running interactively.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 9696a70a5..fb6ce6164 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -280,6 +280,9 @@ if __name__ == "__main__":
 				while in_line:
 					in_line = input("lvm> ")
 					if in_line:
+						if in_line == "exit":
+							shell.exit_shell()
+							sys.exit(0)
 						start = time.time()
 						ret, out, err = shell.call_lvm(in_line.split())
 						end = time.time()

