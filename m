From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:50 +0000 (UTC)
Subject: master - lvmdbusd: Place Manager.UseLvmShell request on queue
Message-ID: <20161117173650.E5F8D60A54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99806ec7ec88c8cade16838ff1c9155fcc861b7e
Commit:        99806ec7ec88c8cade16838ff1c9155fcc861b7e
Parent:        df92d330aaab92445cf93e42db4778757b424792
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 16 17:29:23 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbusd: Place Manager.UseLvmShell request on queue

We need to acquire a lock which can block us which in turn causes
the dbus request handling to block as well.  Place the request on
the work queue instead.
---
 daemons/lvmdbusd/manager.py |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 821c625..bdb08f6 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -158,16 +158,22 @@ class Manager(AutomatedProperties):
 			return p
 		return '/'
 
+	@staticmethod
+	def _use_lvm_shell(yes_no):
+		return dbus.Boolean(cmdhandler.set_execution(yes_no))
+
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,
-		in_signature='b', out_signature='b')
-	def UseLvmShell(self, yes_no):
+		in_signature='b', out_signature='b',
+		async_callbacks=('cb', 'cbe'))
+	def UseLvmShell(self, yes_no, cb, cbe):
 		"""
 		Allow the client to enable/disable lvm shell, used for testing
 		:param yes_no:
 		:return: Nothing
 		"""
-		return dbus.Boolean(cmdhandler.set_execution(yes_no))
+		r = RequestEntry(-1, Manager._use_lvm_shell, (yes_no,), cb, cbe, False)
+		cfg.worker_q.put(r)
 
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,


