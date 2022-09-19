From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:26 +0000 (GMT)
Subject: main - lvmdbusd: Use common function for traceback
Message-ID: <20220919155826.4840E3858285@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb32b0a87f9c2c5b9d79f02e59e3925d8350c70b
Commit:        cb32b0a87f9c2c5b9d79f02e59e3925d8350c70b
Parent:        22942f49162bca9e99172d64dfd03e7a881ce5b2
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 31 11:18:55 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Use common function for traceback

We were using a number of different ways to achieve the same result.  Use
a common function to make this consistent.
---
 daemons/lvmdbusd/cmdhandler.py         | 13 ++++++-------
 daemons/lvmdbusd/lv.py                 |  6 ++----
 daemons/lvmdbusd/lvm_shell_proxy.py.in |  6 +++---
 daemons/lvmdbusd/main.py               |  5 ++---
 daemons/lvmdbusd/objectmanager.py      |  7 +++----
 daemons/lvmdbusd/request.py            |  5 ++---
 daemons/lvmdbusd/utils.py              | 15 ++++++++++-----
 7 files changed, 28 insertions(+), 29 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index d5dceb64e..fd6ecf326 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -13,12 +13,11 @@ import time
 import threading
 from itertools import chain
 import collections
-import traceback
 import os
 
 from lvmdbusd import cfg
 from lvmdbusd.utils import pv_dest_ranges, log_debug, log_error, add_no_notify,\
-							make_non_block, read_decoded
+			make_non_block, read_decoded, extract_stack_trace
 from lvmdbusd.lvm_shell_proxy import LVMShellProxy
 
 try:
@@ -149,8 +148,8 @@ def call_lvm(command, debug=False, line_cb=None,
 					if i != -1:
 						try:
 							line_cb(cb_data, stdout_text[stdout_index:i])
-						except:
-							st = traceback.format_exc()
+						except BaseException as be:
+							st = extract_stack_trace(be)
 							log_error("call_lvm: line_cb exception: \n %s" % st)
 						stdout_index = i + 1
 					else:
@@ -189,11 +188,11 @@ def _shell_cfg():
 		_t_call = lvm_shell.call_lvm
 		cfg.SHELL_IN_USE = lvm_shell
 		return True
-	except Exception:
+	except Exception as e:
 		_t_call = call_lvm
 		cfg.SHELL_IN_USE = None
-		log_error(traceback.format_exc())
-		log_error("Unable to utilize lvm shell, dropping back to fork & exec")
+		log_error("Unable to utilize lvm shell, dropping "
+				  "back to fork & exec\n%s" % extract_stack_trace(e))
 		return False
 
 
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 349ada006..8c55f5ffd 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -24,8 +24,6 @@ from . import background
 from .utils import round_size, mt_remove_dbus_objects
 from .job import JobState
 
-import traceback
-
 
 # Try and build a key for a LV, so that we sort the LVs with least dependencies
 # first.  This may be error prone because of the flexibility LVM
@@ -371,8 +369,8 @@ class LvCommon(AutomatedProperties):
 			return dbus.Struct((self.state.Attr[index],
 				type_map.get(self.state.Attr[index], default)),
 								signature="(ss)")
-		except BaseException:
-			st = traceback.format_exc()
+		except BaseException as b:
+			st = utils.extract_stack_trace(b)
 			log_error("attr_struct: \n%s" % st)
 			return dbus.Struct(('?', 'Unavailable'), signature="(ss)")
 
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index feb93fbfa..77c0078ee 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -14,11 +14,11 @@
 import subprocess
 import shlex
 import os
-import traceback
 import sys
 import tempfile
 import time
 import select
+from .utils import extract_stack_trace
 
 try:
 	import simplejson as json
@@ -279,8 +279,8 @@ if __name__ == "__main__":
 				pass
 			except EOFError:
 				pass
-	except Exception:
-		traceback.print_exc(file=sys.stdout)
+	except Exception as e:
+		log_error("main process exiting on exception!\n%s", extract_stack_trace(e))
 		sys.exit(1)
 
 	sys.exit(0)
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index b485e0245..a426a535d 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -22,7 +22,6 @@ from . import lvmdb
 from gi.repository import GLib
 from .fetch import StateUpdate
 from .manager import Manager
-import traceback
 import queue
 from . import udevwatch
 from .utils import log_debug, log_error, log_msg, DebugMessages
@@ -52,8 +51,8 @@ def process_request():
 			pass
 		except SystemExit:
 			break
-		except Exception:
-			st = traceback.format_exc()
+		except Exception as e:
+			st = utils.extract_stack_trace(e)
 			utils.log_error("process_request exception: \n%s" % st)
 	log_debug("process_request thread exiting!")
 
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index a0c4a50ef..b84e16904 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -9,12 +9,11 @@
 
 import sys
 import threading
-import traceback
 import dbus
 import os
 import copy
 from . import cfg
-from .utils import log_debug, pv_obj_path_generate, log_error
+from .utils import log_debug, pv_obj_path_generate, log_error, extract_stack_trace
 from .automatedproperties import AutomatedProperties
 
 
@@ -40,8 +39,8 @@ class ObjectManager(AutomatedProperties):
 				for k, v in list(obj._objects.items()):
 					path, props = v[0].emit_data()
 					rc[path] = props
-			except Exception:
-				traceback.print_exc(file=sys.stdout)
+			except Exception as e:
+				log_error("_get_managed_objects exception, bailing: \n%s" % extract_stack_trace(e))
 				sys.exit(1)
 			return rc
 
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index 57d72d8af..5d4d7e30a 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -13,8 +13,7 @@ import threading
 from gi.repository import GLib
 from .job import Job
 from . import cfg
-import traceback
-from .utils import log_error, mt_async_call
+from .utils import log_error, mt_async_call, extract_stack_trace
 
 
 class RequestEntry(object):
@@ -86,7 +85,7 @@ class RequestEntry(object):
 			# exception in the journal for figuring out what went wrong.
 			cfg.debug.dump()
 			cfg.flightrecorder.dump()
-			tb = ''.join(traceback.format_tb(e.__traceback__))
+			tb = extract_stack_trace(e)
 			log_error("While processing %s: we encountered\n%s" % (str(self.method), tb))
 			log_error("Error returned to client: %s" % str(e))
 			self.register_error(-1, str(e), e)
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index ae925aa5f..d5c37de46 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -389,8 +389,8 @@ def handler(signum):
 			log_error('Exiting daemon with signal %d' % signum)
 			if cfg.loop is not None:
 				cfg.loop.quit()
-	except:
-		st = traceback.format_exc()
+	except BaseException as be:
+		st = extract_stack_trace(be)
 		log_error("signal handler: exception (logged, not reported!) \n %s" % st)
 
 	# It's important we report that we handled the exception for the exception
@@ -659,9 +659,8 @@ def _async_handler(call_back, parameters):
 			call_back(*parameters)
 		else:
 			call_back()
-	except:
-		st = traceback.format_exc()
-		log_error("mt_async_call: exception (logged, not reported!) \n %s" % st)
+	except BaseException as be:
+		log_error("mt_async_call: exception (logged, not reported!) \n %s" % extract_stack_trace(be))
 
 
 # Execute the function on the main thread with the provided parameters, do
@@ -763,3 +762,9 @@ class LockFile(object):
 
 	def __exit__(self, _type, _value, _traceback):
 		os.close(self.fd)
+
+
+def extract_stack_trace(exception):
+	return ''.join(traceback.format_exception(None, exception, exception.__traceback__))
+
+

