From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 20 Feb 2023 18:22:15 +0000 (GMT)
Subject: main - lvmdbusd: Fix grammar
Message-ID: <20230220182215.429953858CDB@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5561281f0ac4952ecf7d8657291f2887bb7a2927
Commit:        5561281f0ac4952ecf7d8657291f2887bb7a2927
Parent:        a861f0425e0688b2feb97b15277bceb3132d5004
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Feb 16 10:24:06 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Feb 20 12:01:53 2023 -0600

lvmdbusd: Fix grammar

---
 daemons/lvmdbusd/automatedproperties.py |  4 ++--
 daemons/lvmdbusd/background.py          |  2 +-
 daemons/lvmdbusd/cfg.py                 |  4 ++--
 daemons/lvmdbusd/cmdhandler.py          |  4 ++--
 daemons/lvmdbusd/job.py                 |  6 +++---
 daemons/lvmdbusd/loader.py              |  2 +-
 daemons/lvmdbusd/lv.py                  |  4 ++--
 daemons/lvmdbusd/main.py                |  4 ++--
 daemons/lvmdbusd/objectmanager.py       | 10 +++++-----
 daemons/lvmdbusd/request.py             |  2 +-
 daemons/lvmdbusd/utils.py               |  6 +++---
 11 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/daemons/lvmdbusd/automatedproperties.py b/daemons/lvmdbusd/automatedproperties.py
index be41502bd..5ad6b1d27 100644
--- a/daemons/lvmdbusd/automatedproperties.py
+++ b/daemons/lvmdbusd/automatedproperties.py
@@ -44,10 +44,10 @@ class AutomatedProperties(dbus.service.Object):
 
 	def set_interface(self, interface):
 		"""
-		With inheritance we can't easily tell what interfaces a class provides
+		With inheritance, we can't easily tell what interfaces a class provides,
 		so we will have each class that implements an interface tell the
 		base AutomatedProperties what it is they do provide.  This is kind of
-		clunky and perhaps we can figure out a better way to do this later.
+		clunky, and perhaps we can figure out a better way to do this later.
 		:param interface:       An interface the object supports
 		:return:
 		"""
diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 50b19c817..7934a33cf 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -62,7 +62,7 @@ def _move_callback(job_state, line_str):
 def _move_merge(interface_name, command, job_state):
 	# We need to execute these command stand alone by forking & exec'ing
 	# the command always as we will be getting periodic output from them on
-	# the status of the long running operation.
+	# the status of the long-running operation.
 
 	meta = LvmExecutionMeta(time.time(), 0, command)
 	cfg.flightrecorder.add(meta)
diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 70edad846..3ee852855 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -27,13 +27,13 @@ bus = None
 # Command line args
 args = None
 
-# Set to true if we are depending on external events for updates
+# Set to true if we depend on external events for updates
 got_external_event = False
 
 # Shared state variable across all processes
 run = multiprocessing.Value('i', 1)
 
-# If this is set to true, the current setup support lvm shell and we are
+# If this is set to true, the current setup support lvm shell, and we are
 # running in that mode of operation
 SHELL_IN_USE = None
 
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 9a76db4c9..c221e5331 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -109,7 +109,7 @@ def call_lvm(command, debug=False, line_cb=None,
 					stdin, CALL MUST EXECUTE QUICKLY and not *block*
 					otherwise call_lvm function will fail to read
 					stdin/stdout.  Return value of call back is ignored
-	:param cb_data: Supplied to callback to allow caller access to
+	:param cb_data: Supplied to call back to allow caller access to
 								its own data
 
 	# Callback signature
@@ -213,7 +213,7 @@ def _shell_cfg():
 def set_execution(shell):
 	global _t_call
 	with cmd_lock:
-		# If the user requested lvm shell and we are currently setup that
+		# If the user requested lvm shell, and we are currently setup that
 		# way, just return
 		if cfg.SHELL_IN_USE and shell:
 			return True
diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index 7629cafc7..e6d6cfdf3 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -44,7 +44,7 @@ class WaitingClient(object):
 			self.timer_id = GLib.timeout_add_seconds(
 				tmo, WaitingClient._timeout, self)
 
-	# The job finished before the timer popped and we are being notified that
+	# The job finished before the timer popped, and we are being notified that
 	# it's done
 	def notify(self):
 		with self.rlock:
@@ -71,7 +71,7 @@ class JobState(object):
 		self._stderr = ''
 		self._waiting_clients = []
 
-		# This is an lvm command that is just taking too long and doesn't
+		# This is a lvm command that is just taking too long and doesn't
 		# support background operation
 		if self._request:
 			# Faking the percentage when we don't have one
@@ -138,7 +138,7 @@ class JobState(object):
 		# If a waiting client timer pops before the job is done we will allow
 		# the client to remove themselves from the list.  As we have a lock
 		# here and a lock in the waiting client too, and they can be obtained
-		# in different orders, a dead lock can occur.
+		# in different orders, a deadlock can occur.
 		# As this remove is really optional, we will try to acquire the lock
 		# and remove.  If we are unsuccessful it's not fatal, we just delay
 		# the time when the objects can be garbage collected by python
diff --git a/daemons/lvmdbusd/loader.py b/daemons/lvmdbusd/loader.py
index 101502add..548c9dcf4 100644
--- a/daemons/lvmdbusd/loader.py
+++ b/daemons/lvmdbusd/loader.py
@@ -42,7 +42,7 @@ def common(retrieve, o_type, search_keys,
 		existing_paths = cfg.om.object_paths_by_type(o_type)
 
 	for o in objects:
-		# Assume we need to add this one to dbus, unless we are refreshing
+		# Assume we need to add this one to dbus, unless we are refreshing,
 		# and it's already present
 		return_object = True
 
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 30c105342..6a4161ad8 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -25,8 +25,8 @@ from .utils import round_size, mt_remove_dbus_objects, lvm_column_key
 from .job import JobState
 
 
-# Try and build a key for a LV, so that we sort the LVs with least dependencies
-# first.  This may be error prone because of the flexibility LVM
+# Try and build a key for a LV, so that we sort the LVs with the least dependencies
+# first.  This may be error-prone because of the flexibility LVM
 # provides and what you can stack.
 def get_key(i):
 
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index e869bcec3..98b235f4e 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -67,7 +67,7 @@ def check_fr_size(value):
 
 def install_signal_handlers():
 	# Because of the glib main loop stuff the python signal handler code is
-	# apparently not usable and we need to use the glib calls instead
+	# apparently not usable, and we need to use the glib calls instead
 	signal_add = None
 
 	if hasattr(GLib, 'unix_signal_add'):
@@ -208,7 +208,7 @@ def main():
 		thread_list.append(
 			threading.Thread(target=process_request, name='process_request'))
 
-		# Have a single thread handling updating lvm and the dbus model so we
+		# Have a single thread handling updating lvm and the dbus model, so we
 		# don't have multiple threads doing this as the same time
 		updater = StateUpdate()
 		thread_list.append(updater.thread)
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index f9586ec9a..c5ea14bc3 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -159,7 +159,7 @@ class ObjectManager(AutomatedProperties):
 			# print('Registering object path %s for %s' %
 			# (path, dbus_object.lvm_id))
 
-			# We want fast access to the object by a number of different ways
+			# We want fast access to the object by a number of different ways,
 			# so we use multiple hashs with different keys
 			self._lookup_add(dbus_object, path, dbus_object.lvm_id,
 				dbus_object.Uuid)
@@ -209,7 +209,7 @@ class ObjectManager(AutomatedProperties):
 
 	def get_object_by_lvm_id(self, lvm_id):
 		"""
-		Given an lvm identifier, return the object registered for it
+		Given a lvm identifier, return the object registered for it
 		:param lvm_id: The lvm identifier
 		"""
 		with self.rlock:
@@ -220,7 +220,7 @@ class ObjectManager(AutomatedProperties):
 
 	def get_object_path_by_lvm_id(self, lvm_id):
 		"""
-		Given an lvm identifier, return the object path for it
+		Given a lvm identifier, return the object path for it
 		:param lvm_id: The lvm identifier
 		:return: Object path or '/' if not found
 		"""
@@ -295,7 +295,7 @@ class ObjectManager(AutomatedProperties):
 			if uuid == lvm_id:
 				path = self._id_lookup(lvm_id)
 			else:
-				# We have a uuid and a lvm_id we can do sanity checks to ensure
+				# We have an uuid and a lvm_id we can do sanity checks to ensure
 				# that they are consistent
 
 				# If a PV is missing its device path is '[unknown]' or some
@@ -305,7 +305,7 @@ class ObjectManager(AutomatedProperties):
 				if cfg.db.pv_missing(uuid):
 					lvm_id = None
 
-				# Lets check for the uuid first
+				# Let's check for the uuid first
 				path = self._id_lookup(uuid)
 				if path:
 					# Ensure table lookups are correct
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index 5d4d7e30a..69274b20f 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -141,7 +141,7 @@ class RequestEntry(object):
 
 						mt_async_call(self.cb_error, error_exception)
 			else:
-				# We have a job and it's complete, indicate that it's done.
+				# We have a job, and it's complete, indicate that it's done.
 				self._job.Complete = True
 				self._job = None
 
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 0b81591b2..c11737b82 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -90,7 +90,7 @@ def init_class_from_arguments(
 			nt = k
 
 			# If the current attribute has a value, but the incoming does
-			# not, don't overwrite it.  Otherwise the default values on the
+			# not, don't overwrite it.  Otherwise, the default values on the
 			# property decorator don't work as expected.
 			cur = getattr(obj_instance, nt, v)
 
@@ -110,7 +110,7 @@ def init_class_from_arguments(
 
 def get_properties(f):
 	"""
-	Walks through an object instance or it's parent class(es) and determines
+	Walks through an object instance, or it's parent class(es) and determines
 	which attributes are properties and if they were created to be used for
 	dbus.
 	:param f:   Object to inspect
@@ -194,7 +194,7 @@ def add_properties(xml, interface, props):
 				interface_element = c
 				break
 
-		# Interface is not present, lets create it so we have something to
+		# Interface is not present, lets create it, so we have something to
 		# attach the properties too
 		if interface_element is None:
 			interface_element = Et.Element("interface", name=interface)

