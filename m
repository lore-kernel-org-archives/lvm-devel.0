From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:33 +0000 (UTC)
Subject: master - lvmdbusd: Remove unused imports and function parameter
Message-ID: <20160628192433.74DA7611B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c11003c860fe9242f49ba6ccffadd964501f1d1f
Commit:        c11003c860fe9242f49ba6ccffadd964501f1d1f
Parent:        dd5d865020acd545712d4bcc0f3236143de4d76d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 28 12:44:45 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:44:45 2016 -0500

lvmdbusd: Remove unused imports and function parameter

---
 daemons/lvmdbusd/background.py |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index ca3d60e..2c719fc 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -13,9 +13,7 @@ from . import cfg
 import time
 from .cmdhandler import options_to_cli_args
 import dbus
-from .job import Job, JobState
-from .utils import pv_range_append, pv_dest_ranges, log_debug, log_error
-from .request import RequestEntry
+from .utils import pv_range_append, pv_dest_ranges, log_error
 import traceback
 
 _rlock = threading.RLock()
@@ -125,7 +123,7 @@ def background_reaper():
 		time.sleep(3)
 
 
-def background_execute(command, background_job, skip_first_line=False):
+def background_execute(command, background_job):
 
 	# Wrap this whole operation in an exception handler, otherwise if we
 	# hit a code bug we will silently exit this thread without anyone being


