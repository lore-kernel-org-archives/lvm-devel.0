From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:45:00 -0400
Subject: master - testlib.py: Correct dbus signature verification
Message-ID: <201910301545.x9UFj0Nt016861@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed7e365ae5a2b79bf14a3f9772e8e1f663bb6c4f
Commit:        ed7e365ae5a2b79bf14a3f9772e8e1f663bb6c4f
Parent:        5971da2c72a6fe2d83f65a7d6ea7f7bf68971dd8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 9 16:53:34 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

testlib.py: Correct dbus signature verification

This allows us to fully verify introspection data matches what we are
getting.
---
 test/dbus/testlib.py |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index 0335f47..e6655a5 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -145,6 +145,8 @@ def btsr(value):
 		return rc
 	elif t == dbus.Array:
 		rc = "a"
+		if hasattr(value, "signature"):
+			return rc + value.signature
 		for i in value:
 			rc += btsr(i)
 			break
@@ -157,12 +159,9 @@ def verify_type(value, dbus_str_rep):
 	actual_str_rep = btsr(value)
 
 	if dbus_str_rep != actual_str_rep:
-		# print("%s ~= %s" % (dbus_str_rep, actual_str_rep))
-		# Unless we have a full filled out type we won't match exactly
-		if not dbus_str_rep.startswith(actual_str_rep):
-			raise RuntimeError(
-				"Incorrect type, expected= %s actual = %s object= %s" %
-				(dbus_str_rep, actual_str_rep, str(type(value))))
+		raise RuntimeError(
+			"Incorrect type, expected= %s actual = %s object= %s" %
+			(dbus_str_rep, actual_str_rep, str(type(value))))
 
 
 class RemoteInterface(object):


