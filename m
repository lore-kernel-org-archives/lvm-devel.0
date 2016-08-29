From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:29:01 +0000 (UTC)
Subject: master - lvmdbusd: Correct imports
Message-ID: <20160829202901.CB6CE60F09@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96a0604bd036d78af964392460d0309456b58b1a
Commit:        96a0604bd036d78af964392460d0309456b58b1a
Parent:        756f51eac8f42c85f091ebbc4dc8bb2f1569a38e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 14:51:26 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:56 2016 -0500

lvmdbusd: Correct imports

---
 daemons/lvmdbusd/cfg.py             |    6 ++----
 daemons/lvmdbusd/lvm_shell_proxy.py |    9 ++-------
 daemons/lvmdbusd/lvmdb.py           |    8 ++------
 daemons/lvmdbusd/lvmdbusd           |    4 ++--
 daemons/lvmdbusd/utils.py           |    5 +----
 5 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 1d773c3..8965ec7 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -11,10 +11,8 @@ import os
 import multiprocessing
 import queue
 import itertools
-try:
-	from . import path
-except SystemError:
-	import path
+
+from lvmdbusd import path
 
 LVM_CMD = os.getenv('LVM_BINARY', path.LVM_BINARY)
 
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 3455342..910ac2c 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -23,18 +23,13 @@ import select
 import copy
 
 try:
-	from simplejson.scanner import JSONDecodeError
 	import simplejson as json
 except ImportError:
 	import json
 
 
-try:
-	from .cfg import LVM_CMD
-	from .utils import log_debug, log_error
-except:
-	from cfg import LVM_CMD
-	from utils import log_debug, log_error
+from lvmdbusd.cfg import LVM_CMD
+from lvmdbusd.utils import log_debug, log_error
 
 SHELL_PROMPT = "lvm> "
 
diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index 187a930..ac60a80 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -15,12 +15,8 @@ import pprint as prettyprint
 import os
 import sys
 
-try:
-	from . import cmdhandler
-	from .utils import log_debug, log_error
-except SystemError:
-	import cmdhandler
-	from utils import log_debug
+from lvmdbusd import cmdhandler
+from lvmdbusd.utils import log_debug, log_error
 
 
 class DataStore(object):
diff --git a/daemons/lvmdbusd/lvmdbusd b/daemons/lvmdbusd/lvmdbusd
index 7ea243b..73d0f13 100755
--- a/daemons/lvmdbusd/lvmdbusd
+++ b/daemons/lvmdbusd/lvmdbusd
@@ -10,7 +10,7 @@
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 import sys
-import lvmdbusd
+from lvmdbusd import main
 
 if __name__ == '__main__':
-	sys.exit(lvmdbusd.main())
+	sys.exit(main())
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index c80290f..06301cd 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -18,11 +18,8 @@ import datetime
 import dbus
 import dbus.service
 import dbus.mainloop.glib
+from lvmdbusd import cfg
 
-try:
-	from . import cfg
-except SystemError:
-	import cfg
 
 STDOUT_TTY = os.isatty(sys.stdout.fileno())
 


