From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:19 +0000 (GMT)
Subject: main - lvmdbusd: Don't report recoverable error
Message-ID: <20220919155819.723BE385842E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0296e56073667216e6b1d7397880b02df8df54c8
Commit:        0296e56073667216e6b1d7397880b02df8df54c8
Parent:        29189948732b4385fa053c94ac2dc31e3cfc3dfa
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Aug 25 09:33:50 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Don't report recoverable error

Lvm occasionally fails to return all the request JSON keys in the output of
"fullreport".  This happens very rarely.  When it does the daemon was reporting
the resulting informational exception:

MThreadRunner: exception
Traceback (most recent call last):
  File "/usr/lib/python3.9/site-packages/lvmdbusd/utils.py", line 667, in _run
    self.rc = self.f(*self.args)
  File "/usr/lib/python3.9/site-packages/lvmdbusd/fetch.py", line 40, in _main_thread_load
    (lv_changes, remove) = load_lvs(
  File "/usr/lib/python3.9/site-packages/lvmdbusd/lv.py", line 143, in load_lvs
    return common(
  File "/usr/lib/python3.9/site-packages/lvmdbusd/loader.py", line 37, in common
    objects = retrieve(search_keys, cache_refresh=False)
  File "/usr/lib/python3.9/site-packages/lvmdbusd/lv.py", line 95, in lvs_state_retrieve
    l['vdo_operating_mode'],
KeyError: 'vdo_operating_mode'

The daemon retries the operation, which usually works and the daemon continues.
However, simply reporting this informational stack trace is causing CI and other
automated tests to fail as they expect no tracebacks in the log output.

Remove the reporting of this code path unless it persists and causes the daemon
to give up and exit.

Ref: https://bugzilla.redhat.com/show_bug.cgi?id=2120267
---
 daemons/lvmdbusd/fetch.py | 10 ++++------
 daemons/lvmdbusd/utils.py |  3 ---
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index ed519b660..5cb98853a 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -193,16 +193,14 @@ class StateUpdate(object):
 			except queue.Empty:
 				pass
 			except Exception as e:
-				st = traceback.format_exc()
-				log_error("update_thread exception: \n%s" % st)
-				cfg.debug.dump()
-				cfg.flightrecorder.dump()
 				exception_count += 1
 				if exception_count >= 5:
+					st = traceback.format_exc()
+					log_error("Too many errors in update_thread, exiting daemon (last exception reported): \n %s" % st)
+					cfg.debug.dump()
+					cfg.flightrecorder.dump()
 					bailing(e)
-					log_error("Too many errors in update_thread, exiting daemon")
 					cfg.exit_daemon()
-
 				else:
 					# Slow things down when encountering errors
 					time.sleep(1)
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 802f71173..ae925aa5f 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -711,9 +711,6 @@ class MThreadRunner(object):
 				self.rc = self.f()
 		except BaseException as be:
 			self.exception = be
-			st = traceback.format_exc()
-			log_error("MThreadRunner: exception \n %s" % st)
-			log_error("Exception will be raised in calling thread!")
 
 
 def _remove_objects(dbus_objects_rm):

