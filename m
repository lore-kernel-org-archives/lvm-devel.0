From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:39 +0000 (GMT)
Subject: main - lvmdbusd: re-work lvm shell main
Message-ID: <20220630160039.38444386F0C1@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3407b16c1c7b5bff01e3bde4e0f62a2608682f8
Commit:        b3407b16c1c7b5bff01e3bde4e0f62a2608682f8
Parent:        58c6c9e9aa8d6aa6d3be14a04ec0f4257b61495e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed May 25 15:58:15 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: re-work lvm shell main

Add an optional single argument "bisect" to use with git bisect for
automation.  Normal case is no arguments when running stand-alone.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 46 +++++++++++++++++++++-------------
 1 file changed, 28 insertions(+), 18 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 10719c67e..40639442c 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -238,24 +238,34 @@ class LVMShellProxy(object):
 
 
 if __name__ == "__main__":
-	shell = LVMShellProxy()
-	in_line = "start"
+	print("USING LVM BINARY: %s " % LVM_CMD)
+
 	try:
-		while in_line:
-			in_line = input("lvm> ")
-			if in_line:
-				start = time.time()
-				ret, out, err = shell.call_lvm(in_line.split())
-				end = time.time()
-
-				print(("RC: %d" % ret))
-				print(("OUT:\n%s" % out))
-				print(("ERR:\n%s" % err))
-
-				print("Command     = %f seconds" % (end - start))
-	except KeyboardInterrupt:
-		pass
-	except EOFError:
-		pass
+		if len(sys.argv) > 1 and sys.argv[1] == "bisect":
+			shell = LVMShellProxy()
+			shell.exit_shell()
+		else:
+			shell = LVMShellProxy()
+			in_line = "start"
+			try:
+				while in_line:
+					in_line = input("lvm> ")
+					if in_line:
+						start = time.time()
+						ret, out, err = shell.call_lvm(in_line.split())
+						end = time.time()
+
+						print(("RC: %d" % ret))
+						print(("OUT:\n%s" % out))
+						print(("ERR:\n%s" % err))
+
+						print("Command     = %f seconds" % (end - start))
+			except KeyboardInterrupt:
+				pass
+			except EOFError:
+				pass
 	except Exception:
 		traceback.print_exc(file=sys.stdout)
+		sys.exit(1)
+
+	sys.exit(0)

