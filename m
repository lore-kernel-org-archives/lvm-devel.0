From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:49 +0000 (GMT)
Subject: main - lvmdbusd: Add lockfile
Message-ID: <20220919155749.E9B533858C53@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3fdf4493481ff8baae2ac5416dce6d05b69e6b28
Commit:        3fdf4493481ff8baae2ac5416dce6d05b69e6b28
Parent:        1a4384979cdf889bd63a932d83933079c53490ae
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 8 20:48:10 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbusd: Add lockfile

The daemon cannot handle multiple copies of itself running at the
same time, ensure this cannot happen.
---
 daemons/lvmdbusd/cfg.py   |   2 +
 daemons/lvmdbusd/main.py  | 111 +++++++++++++++++++++++-----------------------
 daemons/lvmdbusd/utils.py |  37 ++++++++++++++--
 3 files changed, 92 insertions(+), 58 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 684c2b208..ee4e41b30 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -16,6 +16,8 @@ from lvmdbusd import path
 
 LVM_CMD = os.getenv('LVM_BINARY', path.LVM_BINARY)
 
+LOCK_FILE = os.getenv("LVM_DBUSD_LOCKFILE", "/var/lock/lvm/lvmdbusd")
+
 # This is the global object manager
 om = None
 
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 1e883c901..7b455052e 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -154,61 +154,62 @@ def main():
 
 	install_signal_handlers()
 
-	dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
-	dbus.mainloop.glib.threads_init()
+	with utils.LockFile(cfg.LOCK_FILE):
+		dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
+		dbus.mainloop.glib.threads_init()
 
-	cmdhandler.set_execution(cfg.args.use_lvm_shell)
+		cmdhandler.set_execution(cfg.args.use_lvm_shell)
 
-	if use_session:
-		cfg.bus = dbus.SessionBus()
-	else:
-		cfg.bus = dbus.SystemBus()
-	# The base name variable needs to exist for things to work.
-	# noinspection PyUnusedLocal
-	base_name = dbus.service.BusName(BUS_NAME, cfg.bus)
-	cfg.om = Lvm(BASE_OBJ_PATH)
-	cfg.om.register_object(Manager(MANAGER_OBJ_PATH))
-
-	cfg.db = lvmdb.DataStore(vdo_support=cfg.vdo_support)
-
-	# Using a thread to process requests, we cannot hang the dbus library
-	# thread that is handling the dbus interface
-	thread_list.append(
-		threading.Thread(target=process_request, name='process_request'))
-
-	# Have a single thread handling updating lvm and the dbus model so we
-	# don't have multiple threads doing this as the same time
-	updater = StateUpdate()
-	thread_list.append(updater.thread)
-
-	cfg.load = updater.load
-
-	cfg.loop = GLib.MainLoop()
-
-	for thread in thread_list:
-		thread.damon = True
-		thread.start()
-
-	# In all cases we are going to monitor for udev until we get an
-	# ExternalEvent.  In the case where we get an external event and the user
-	# didn't specify --udev we will stop monitoring udev
-	udevwatch.add()
-
-	end = time.time()
-	log_debug(
-		'Service ready! total time= %.4f, lvm time= %.4f count= %d' %
-		(end - start, cmdhandler.total_time, cmdhandler.total_count),
-		'bg_black', 'fg_light_green')
-
-	try:
-		if cfg.run.value != 0:
-			cfg.loop.run()
-			udevwatch.remove()
-
-			for thread in thread_list:
-				thread.join()
-	except KeyboardInterrupt:
-		# If we are unable to register signal handler, we will end up here when
-		# the service gets a ^C or a kill -2 <parent pid>
-		utils.handler(signal.SIGINT)
+		if use_session:
+			cfg.bus = dbus.SessionBus()
+		else:
+			cfg.bus = dbus.SystemBus()
+		# The base name variable needs to exist for things to work.
+		# noinspection PyUnusedLocal
+		base_name = dbus.service.BusName(BUS_NAME, cfg.bus)
+		cfg.om = Lvm(BASE_OBJ_PATH)
+		cfg.om.register_object(Manager(MANAGER_OBJ_PATH))
+
+		cfg.db = lvmdb.DataStore(vdo_support=cfg.vdo_support)
+
+		# Using a thread to process requests, we cannot hang the dbus library
+		# thread that is handling the dbus interface
+		thread_list.append(
+			threading.Thread(target=process_request, name='process_request'))
+
+		# Have a single thread handling updating lvm and the dbus model so we
+		# don't have multiple threads doing this as the same time
+		updater = StateUpdate()
+		thread_list.append(updater.thread)
+
+		cfg.load = updater.load
+
+		cfg.loop = GLib.MainLoop()
+
+		for thread in thread_list:
+			thread.damon = True
+			thread.start()
+
+		# In all cases we are going to monitor for udev until we get an
+		# ExternalEvent.  In the case where we get an external event and the user
+		# didn't specify --udev we will stop monitoring udev
+		udevwatch.add()
+
+		end = time.time()
+		log_debug(
+			'Service ready! total time= %.4f, lvm time= %.4f count= %d' %
+			(end - start, cmdhandler.total_time, cmdhandler.total_count),
+			'bg_black', 'fg_light_green')
+
+		try:
+			if cfg.run.value != 0:
+				cfg.loop.run()
+				udevwatch.remove()
+
+				for thread in thread_list:
+					thread.join()
+		except KeyboardInterrupt:
+			# If we are unable to register signal handler, we will end up here when
+			# the service gets a ^C or a kill -2 <parent pid>
+			utils.handler(signal.SIGINT)
 	return 0
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index f5bca1b46..d24a34935 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -11,10 +11,12 @@ import xml.etree.ElementTree as Et
 import sys
 import inspect
 import ctypes
+import errno
+import fcntl
 import os
+import stat
 import string
 import datetime
-from fcntl import fcntl, F_GETFL, F_SETFL
 
 import dbus
 from lvmdbusd import cfg
@@ -690,8 +692,8 @@ def mt_remove_dbus_objects(objs):
 
 # Make stream non-blocking
 def make_non_block(stream):
-	flags = fcntl(stream, F_GETFL)
-	fcntl(stream, F_SETFL, flags | os.O_NONBLOCK)
+	flags = fcntl.fcntl(stream, fcntl.F_GETFL)
+	fcntl.fcntl(stream, fcntl.F_SETFL, flags | os.O_NONBLOCK)
 
 
 def read_decoded(stream):
@@ -699,3 +701,32 @@ def read_decoded(stream):
 	if tmp:
 		return tmp.decode("utf-8")
 	return ''
+
+
+class LockFile(object):
+	"""
+	Simple lock file class
+	Based on Pg.1144 "The Linux Programming Interface" by Michael Kerrisk
+	"""
+	def __init__(self, lock_file):
+		self.fd = 0
+		self.lock_file = lock_file
+
+	def __enter__(self):
+		try:
+			self.fd = os.open(self.lock_file, os.O_CREAT | os.O_RDWR, stat.S_IRUSR | stat.S_IWUSR)
+
+			# Get and set the close on exec and lock the file
+			flags = fcntl.fcntl(self.fd, fcntl.F_GETFD)
+			flags |= fcntl.FD_CLOEXEC
+			fcntl.fcntl(self.fd, fcntl.F_SETFL, flags)
+			fcntl.lockf(self.fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
+		except OSError as e:
+			if e.errno == errno.EAGAIN:
+				log_error("Daemon already running, exiting!")
+			else:
+				log_error("Error during creation of lock file(%s): errno(%d), exiting!" % (self.lock_file, e.errno))
+			sys.exit(114)
+
+	def __exit__(self, _type, _value, _traceback):
+		os.close(self.fd)

