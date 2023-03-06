From: Tony Asleson <tasleson@sourceware.org>
Date: Mon,  6 Mar 2023 17:26:16 +0000 (GMT)
Subject: main - lvmdbusd: Move cfg.lvmdebug data init
Message-ID: <20230306172616.1DA353858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df6120e9f715c58327451f650c003d09842f33c7
Commit:        df6120e9f715c58327451f650c003d09842f33c7
Parent:        8e27dfd40576f4e2828b169bfe18d8cae9968244
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Mar 6 10:25:22 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 6 10:25:22 2023 -0600

lvmdbusd: Move cfg.lvmdebug data init

Move this to the cfg file itself, so that initialization runs when it
gets processed.
---
 daemons/lvmdbusd/cfg.py  | 8 +++++---
 daemons/lvmdbusd/main.py | 5 -----
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 3ee852855..9da4b1267 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -11,6 +11,7 @@ import os
 import multiprocessing
 import queue
 import itertools
+from utils import LvmDebugData
 
 from lvmdbusd import path
 
@@ -18,6 +19,10 @@ LVM_CMD = os.getenv('LVM_BINARY', path.LVM_BINARY)
 
 LOCK_FILE = os.getenv("LVM_DBUSD_LOCKFILE", "/var/lock/lvm/lvmdbusd")
 
+# Save off the debug data needed for lvm team to debug issues
+# only used for 'fullreport' at this time.
+lvmdebug = LvmDebugData(os.getenv('LVM_DBUSD_COLLECT_LVM_DEBUG', False))
+
 # This is the global object manager
 om = None
 
@@ -114,7 +119,4 @@ def exit_daemon():
         loop.quit()
 
 
-# Debug data for lvm
-lvmdebug = None
-
 systemd = False
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index e8bd3ce0e..e07710a5e 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -148,17 +148,12 @@ def running_under_systemd():
 def main():
 	start = time.time()
 	use_session = os.getenv('LVM_DBUSD_USE_SESSION', False)
-	collect_lvm_debug = os.getenv('LVM_DBUSD_COLLECT_LVM_DEBUG', False)
 
 	# Ensure that we get consistent output for parsing stdout/stderr and that we
 	# are using the lvmdbusd profile.
 	os.environ["LC_ALL"] = "C"
 	os.environ["LVM_COMMAND_PROFILE"] = "lvmdbusd"
 
-	# Save off the debug data needed for lvm team to debug issues
-	# only used for 'fullreport' at this time.
-	cfg.lvmdebug = utils.LvmDebugData(collect_lvm_debug)
-
 	# Indicator if we are running under systemd
 	cfg.systemd = running_under_systemd()
 

