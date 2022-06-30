From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:44 +0000 (GMT)
Subject: main - lvmdbusd: Job prop. Get/GetAll exec. immediately
Message-ID: <20220630160044.DBCDA386F0D0@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eee89a941eb4e63865356cfe9e513c24cfa8e0f9
Commit:        eee89a941eb4e63865356cfe9e513c24cfa8e0f9
Parent:        7a2090655d3ab5abde83b981594ed527e2a7f1f7
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 6 09:51:54 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: Job prop. Get/GetAll exec. immediately

This allows API user the ability to check on the status of a long running
job without blocking in the request queue.
---
 daemons/lvmdbusd/job.py | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index 988b1147a..7629cafc7 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -226,3 +226,21 @@ class Job(AutomatedProperties):
 	def Uuid(self):
 		import uuid
 		return uuid.uuid1()
+
+	# Override the property "getters" implementation for the job interface, so a user can query a job while the queue
+	# is processing items.  Originally all the property get methods were this way, but we changed this in
+	# e53454d6de07de56736303dd2157c3859f6fa848
+
+	# Properties
+	# noinspection PyUnusedLocal
+	@dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
+						 in_signature='ss', out_signature='v')
+	def Get(self, interface_name, property_name):
+		# Note: If we get an exception in this handler we won't know about it,
+		# only the side effect of no returned value!
+		return AutomatedProperties._get_prop(self, interface_name, property_name)
+
+	@dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
+						 in_signature='s', out_signature='a{sv}')
+	def GetAll(self, interface_name):
+		return AutomatedProperties._get_all_prop(self, interface_name)

