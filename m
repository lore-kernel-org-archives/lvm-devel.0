From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:41:17 -0500
Subject: master - lvmdbusd: Add FlightRecorderDump
Message-ID: <201703092241.v29MfH5W011839@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=470a1f1c5031590823f8a58e641873da76dc1f46
Commit:        470a1f1c5031590823f8a58e641873da76dc1f46
Parent:        f2d7a48418df7ce6071e4276a4a2cf0dd47570d4
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 8 13:32:20 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbusd: Add FlightRecorderDump

Diagnostic method for dumping flight recorder to syslog.
---
 daemons/lvmdbusd/manager.py |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 41bb22a..5575e39 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -133,6 +133,13 @@ class Manager(AutomatedProperties):
 		cfg.worker_q.put(r)
 
 	@dbus.service.method(
+		dbus_interface=MANAGER_INTERFACE)
+	def FlightRecorderDump(self):
+		"""
+		Dump the flight recorder to syslog
+		"""
+		cfg.blackbox.dump()
+	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,
 		in_signature='s',
 		out_signature='o')


