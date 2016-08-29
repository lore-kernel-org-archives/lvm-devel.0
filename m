From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:29:05 +0000 (UTC)
Subject: master - lvmdbusd: WS/pep8 corrections
Message-ID: <20160829202905.EB70560F09@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5392a612dc722fa9ca20959f362cd8c130b5ab48
Commit:        5392a612dc722fa9ca20959f362cd8c130b5ab48
Parent:        1870b3293a26f6d946e8451a10e8c9762ae9f31c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 15:07:55 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:28:06 2016 -0500

lvmdbusd: WS/pep8 corrections

---
 daemons/lvmdbusd/background.py      |   10 +++++-----
 daemons/lvmdbusd/cmdhandler.py      |    1 +
 daemons/lvmdbusd/lv.py              |   12 ++++++------
 daemons/lvmdbusd/lvm_shell_proxy.py |    3 +--
 daemons/lvmdbusd/main.py            |   32 ++++++++++++++++++--------------
 daemons/lvmdbusd/manager.py         |    1 +
 daemons/lvmdbusd/objectmanager.py   |    2 +-
 7 files changed, 33 insertions(+), 28 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 0c0b509..6190f0d 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -135,11 +135,11 @@ def background_execute(command, background_job):
 		# the command always!
 		command.insert(0, cfg.LVM_CMD)
 		process = subprocess.Popen(command, stdout=subprocess.PIPE,
-								   env=os.environ,
+									env=os.environ,
 									stderr=subprocess.PIPE, close_fds=True)
 
 		log_debug("Background process for %s is %d" %
-				  (str(command), process.pid))
+					(str(command), process.pid))
 
 		lines_iterator = iter(process.stdout.readline, b"")
 		for line in lines_iterator:
@@ -149,8 +149,8 @@ def background_execute(command, background_job):
 			try:
 				if line_str.count(':') == 2:
 					(device, ignore, percentage) = line_str.split(':')
-					background_job.Percent = \
-						round(float(percentage.strip()[:-1]), 1)
+					background_job.Percent = round(
+						float(percentage.strip()[:-1]), 1)
 			except ValueError:
 				log_error("Trying to parse percentage which failed for %s" %
 					line_str)
@@ -161,7 +161,7 @@ def background_execute(command, background_job):
 			background_job.Percent = 100
 		else:
 			log_error("Failed to execute background job %s, STDERR= %s"
-					  % (str(command), out[1]))
+						% (str(command), out[1]))
 
 		background_job.set_result(process.returncode, out[1])
 		log_debug("Background process %d complete!" % process.pid)
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 9b0c877..2739497 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -120,6 +120,7 @@ def call_lvm(command, debug=False):
 # from forking a new process to using lvm shell
 _t_call = call_lvm
 
+
 def _shell_cfg():
 	global _t_call
 	try:
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 3d0b78c..4ec6f23 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -260,7 +260,7 @@ class LvCommon(AutomatedProperties):
 					'e': 'raid or pool metadata or pool metadata spare',
 					'-': 'Unspecified'}
 		return dbus.Struct((self.state.Attr[0], type_map[self.state.Attr[0]]),
-						   signature="as")
+						signature="as")
 
 	@property
 	def Permissions(self):
@@ -268,7 +268,7 @@ class LvCommon(AutomatedProperties):
 					'R': 'Read-only activation of non-read-only volume',
 					'-': 'Unspecified'}
 		return dbus.Struct((self.state.Attr[1], type_map[self.state.Attr[1]]),
-						   signature="(ss)")
+						signature="(ss)")
 
 	@property
 	def AllocationPolicy(self):
@@ -278,7 +278,7 @@ class LvCommon(AutomatedProperties):
 					'l': 'cling', 'L': 'cling locked',
 					'n': 'normal', 'N': 'normal locked', '-': 'Unspecified'}
 		return dbus.Struct((self.state.Attr[2], type_map[self.state.Attr[2]]),
-						   signature="(ss)")
+						signature="(ss)")
 
 	@property
 	def FixedMinor(self):
@@ -294,7 +294,7 @@ class LvCommon(AutomatedProperties):
 					'i': 'mapped device present with inactive table',
 					'X': 'unknown', '-': 'Unspecified'}
 		return dbus.Struct((self.state.Attr[4], type_map[self.state.Attr[4]]),
-						   signature="(ss)")
+						signature="(ss)")
 
 	@property
 	def TargetType(self):
@@ -302,7 +302,7 @@ class LvCommon(AutomatedProperties):
 					's': 'snapshot', 't': 'thin', 'u': 'unknown',
 					'v': 'virtual', '-': 'Unspecified'}
 		return dbus.Struct((self.state.Attr[6], type_map[self.state.Attr[6]]),
-						   signature="(ss)")
+						signature="(ss)")
 
 	@property
 	def ZeroBlocks(self):
@@ -314,7 +314,7 @@ class LvCommon(AutomatedProperties):
 					'm': 'mismatches', 'w': 'writemostly',
 					'X': 'X unknown', '-': 'Unspecified'}
 		return dbus.Struct((self.state.Attr[8], type_map[self.state.Attr[8]]),
-						   signature="(ss)")
+					signature="(ss)")
 
 	@property
 	def SkipActivation(self):
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 910ac2c..12e7e36 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -115,7 +115,6 @@ class LVMShellProxy(object):
 		local_env["LVM_REPORT_FD"] = "32"
 		local_env["LVM_COMMAND_PROFILE"] = "lvmdbusd"
 
-
 		flags = fcntl(self.report_r, F_GETFL)
 		fcntl(self.report_r, F_SETFL, flags | os.O_NONBLOCK)
 
@@ -223,7 +222,7 @@ if __name__ == "__main__":
 				end = time.time()
 
 				print(("RC: %d" % ret))
-				#print(("OUT:\n%s" % out))
+				# print(("OUT:\n%s" % out))
 				print(("ERR:\n%s" % err))
 
 				print("Command     = %f seconds" % (end - start))
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 5cf522d..65a66db 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -96,20 +96,24 @@ def main():
 	start = time.time()
 	# Add simple command line handling
 	parser = argparse.ArgumentParser()
-	parser.add_argument("--udev", action='store_true',
-						help="Use udev for updating state", default=False,
-						dest='use_udev')
-	parser.add_argument("--debug", action='store_true',
-						help="Dump debug messages", default=False,
-						dest='debug')
-	parser.add_argument("--nojson", action='store_false',
-						help="Do not use LVM JSON output (Note: This "
-							"does not work with --lvmshell", default=True,
-						dest='use_json')
-	parser.add_argument("--lvmshell", action='store_true',
-						help="Use the lvm shell, not fork & exec lvm",
-						default=False,
-						dest='use_lvm_shell')
+	parser.add_argument(
+		"--udev", action='store_true',
+		help="Use udev for updating state",
+		default=False,
+		dest='use_udev')
+	parser.add_argument(
+		"--debug", action='store_true',
+		help="Dump debug messages", default=False,
+		dest='debug')
+	parser.add_argument(
+		"--nojson", action='store_false',
+		help="Do not use LVM JSON output (disables lvmshell)", default=True,
+		dest='use_json')
+	parser.add_argument(
+		"--lvmshell", action='store_true',
+		help="Use the lvm shell, not fork & exec lvm",
+		default=False,
+		dest='use_lvm_shell')
 
 	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
 
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index b141929..b7d7b10 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -19,6 +19,7 @@ from .request import RequestEntry
 from .refresh import event_add
 from . import udevwatch
 
+
 # noinspection PyPep8Naming
 class Manager(AutomatedProperties):
 	_Version_meta = ("s", MANAGER_INTERFACE)
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index 178003e..0b810d8 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -125,7 +125,7 @@ class ObjectManager(AutomatedProperties):
 			path, props = dbus_object.emit_data()
 
 			# print('Registering object path %s for %s' %
-			#		(path, dbus_object.lvm_id))
+			# (path, dbus_object.lvm_id))
 
 			# We want fast access to the object by a number of different ways
 			# so we use multiple hashs with different keys


