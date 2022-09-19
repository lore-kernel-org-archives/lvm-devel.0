From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:11 +0000 (GMT)
Subject: main - lvmdbustest: Add test_sigint test
Message-ID: <20220919155811.7B3133858424@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d16c0a3e2bc1d36fc11ed763ac32184f09c6c67c
Commit:        d16c0a3e2bc1d36fc11ed763ac32184f09c6c67c
Parent:        52415b5708aa26fe322b13a9ffdb8cc16904ab45
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 23 10:30:53 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Add test_sigint test

Get the daemon busy and send it SIGINT to ensure the daemon exits.
---
 test/dbus/lvmdbustest.py | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 2f1aa98a6..7a03c46a2 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2303,6 +2303,41 @@ class TestDbusService(unittest.TestCase):
 				self.assertTrue('Job is not complete!' in str(e))
 				raise e
 
+	def test_sigint(self):
+		# Issue SIGINT while daemon is processing work to ensure we shut down.
+		di = DaemonInfo.get()
+		self.assertTrue(di is not None)
+		if di:
+			# Find out how long it takes to create a VG and a number of LVs
+			# we will then issue the creation of the LVs async., wait, then issue a signal
+			# and repeat stepping through the entire time range.
+			start = time.time()
+			vg_proxy = self._create_num_lvs(20)
+			end = time.time()
+
+			self.handle_return(vg_proxy.Vg.Remove(dbus.Int32(g_tmo), EOD))
+			total = end - start
+
+			for i in range(5):
+				sleep_amt = i * (total/5.0)
+				self._create_num_lvs(20, True)
+				time.sleep(sleep_amt)
+
+				exited = False
+				try:
+					di.term_signal(signal.SIGINT)
+					exited = True
+				except Exception:
+					std_err_print("Failed to exit on SIGINT, sending SIGKILL...")
+					di.term_signal(signal.SIGKILL)
+				finally:
+					di.start()
+					self.clean_up()
+
+				self.assertTrue(exited,
+								"Failed to exit after sending signal %f seconds after "
+								"queuing up work for signal %d" % (sleep_amt, signal.SIGINT))
+
 
 class AggregateResults(object):
 

