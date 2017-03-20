From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 20 Mar 2017 11:10:58 -0400
Subject: master - lvmdbusd: Limit state refreshes for udev events
Message-ID: <201703201510.v2KFAw1p025707@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ead4fb7ac3006a4c4377a88da22c22e6d426035
Commit:        3ead4fb7ac3006a4c4377a88da22c22e6d426035
Parent:        7eeb093fdd314063eff7f14b8b6338523e0dd840
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 15 13:08:19 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 20 10:08:39 2017 -0500

lvmdbusd: Limit state refreshes for udev events

Udev events can come in like a flood when something changes.  It really
doesn't do us any good to refresh the state of the service numerous times
when 1 would suffice.  We had something like this before, but it was
removed when we added the refresh thread.  However, we have since learned
that we need to sequence events in the correct order and block dbus
operations if we believe the state has been affected, thus udev events are
being processed on the main work queue.  This change limits spurious
work items from getting to the queue.
---
 daemons/lvmdbusd/udevwatch.py |   29 +++++++++++++++++++++++++----
 1 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/udevwatch.py b/daemons/lvmdbusd/udevwatch.py
index eaf31df..b53b180 100644
--- a/daemons/lvmdbusd/udevwatch.py
+++ b/daemons/lvmdbusd/udevwatch.py
@@ -16,9 +16,33 @@ from . import utils
 observer = None
 observer_lock = threading.RLock()
 
+_udev_lock = threading.RLock()
+_udev_count = 0
+
+
+def udev_add():
+	global _udev_count
+	with _udev_lock:
+		if _udev_count == 0:
+			_udev_count += 1
+
+			# Place this on the queue so any other operations will sequence
+			# behind it
+			r = RequestEntry(
+				-1, _udev_event, (), None, None, False)
+			cfg.worker_q.put(r)
+
+
+def udev_complete():
+	global _udev_count
+	with _udev_lock:
+		if _udev_count > 0:
+			_udev_count -= 1
+
 
 def _udev_event():
 	utils.log_debug("Processing udev event")
+	udev_complete()
 	cfg.load()
 
 
@@ -44,10 +68,7 @@ def filter_event(action, device):
 		refresh = True
 
 	if refresh:
-		# Place this on the queue so any other operations will sequence behind it
-		r = RequestEntry(
-			-1, _udev_event, (), None, None, False)
-		cfg.worker_q.put(r)
+		udev_add()
 
 
 def add():


