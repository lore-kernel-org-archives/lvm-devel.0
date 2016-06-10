From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Jun 2016 21:06:29 +0000 (UTC)
Subject: master - lvmdbusd: Change print statement to py3 syntax
Message-ID: <20160610210629.7825D60E3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=41ebed707700e926d4224bc62289ea47014d9a0d
Commit:        41ebed707700e926d4224bc62289ea47014d9a0d
Parent:        b717c5efae942c845f07d695593cfb2406627fe9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 6 15:06:50 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 10 15:28:42 2016 -0500

lvmdbusd: Change print statement to py3 syntax

---
 daemons/lvmdbusd/objectmanager.py |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index f28c5c8..f8f6d97 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -124,8 +124,8 @@ class ObjectManager(AutomatedProperties):
 		with self.rlock:
 			path, props = dbus_object.emit_data()
 
-			# print 'Registering object path %s for %s' %
-			# (path, dbus_object.lvm_id)
+			# print('Registering object path %s for %s' %
+			#		(path, dbus_object.lvm_id))
 
 			# We want fast access to the object by a number of different ways
 			# so we use multiple hashs with different keys


