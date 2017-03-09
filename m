From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:42:20 -0500
Subject: master - lvmdbustest.py: Correct call_lvm doc
Message-ID: <201703092242.v29MgKAY018250@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee7946ed82e11b5d22b02b67821661ff3e3a0993
Commit:        ee7946ed82e11b5d22b02b67821661ff3e3a0993
Parent:        957e283de8298e2bb83517dbf8b724bc733cbbd9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 16:06:24 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbustest.py: Correct call_lvm doc

---
 test/dbus/lvmdbustest.py |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 2a65466..6c928e2 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -119,7 +119,9 @@ def call_lvm(command):
 	"""
 	Call lvm executable and return a tuple of exitcode, stdout, stderr
 	:param command:     Command to execute
-	:param debug:       Dump debug to stdout
+	:type command: 		list
+	:returns (exitcode, stdout, stderr)
+	:rtype (int, str, str)
 	"""
 
 	# Prepend the full lvm executable so that we can run different versions


