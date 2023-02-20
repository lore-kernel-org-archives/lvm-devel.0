From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 20 Feb 2023 18:22:16 +0000 (GMT)
Subject: main - lvmdbusd: Disable collecting lvm debug data by default
Message-ID: <20230220182216.649B83858C2F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e18d60b336ac881599c1c68d9d3fff1ac8b6515d
Commit:        e18d60b336ac881599c1c68d9d3fff1ac8b6515d
Parent:        5561281f0ac4952ecf7d8657291f2887bb7a2927
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Feb 16 16:07:32 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Feb 20 12:01:53 2023 -0600

lvmdbusd: Disable collecting lvm debug data by default

---
 daemons/lvmdbusd/cmdhandler.py |  5 ++++-
 daemons/lvmdbusd/main.py       |  3 ++-
 daemons/lvmdbusd/utils.py      | 11 ++++++++---
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index c221e5331..ea7e300cf 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -626,8 +626,11 @@ def lvm_full_report_json():
 
 	# We are running the fullreport command, we will ask lvm to output the debug
 	# data, so we can have the required information for lvm to debug the fullreport failures.
+	# Note: this is disabled by default and can be enabled with env. var.
+	# LVM_DBUSD_COLLECT_LVM_DEBUG=True
 	fn = cfg.lvmdebug.setup()
-	add_config_option(cmd, "--config", "log {level=7 file=%s syslog=0}" % fn)
+	if fn is not None:
+		add_config_option(cmd, "--config", "log {level=7 file=%s syslog=0}" % fn)
 
 	rc, out, err = call(cmd)
 	# When we have an exported vg the exit code of lvs or fullreport will be 5
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 98b235f4e..e8bd3ce0e 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -148,6 +148,7 @@ def running_under_systemd():
 def main():
 	start = time.time()
 	use_session = os.getenv('LVM_DBUSD_USE_SESSION', False)
+	collect_lvm_debug = os.getenv('LVM_DBUSD_COLLECT_LVM_DEBUG', False)
 
 	# Ensure that we get consistent output for parsing stdout/stderr and that we
 	# are using the lvmdbusd profile.
@@ -156,7 +157,7 @@ def main():
 
 	# Save off the debug data needed for lvm team to debug issues
 	# only used for 'fullreport' at this time.
-	cfg.lvmdebug = utils.LvmDebugData()
+	cfg.lvmdebug = utils.LvmDebugData(collect_lvm_debug)
 
 	# Indicator if we are running under systemd
 	cfg.systemd = running_under_systemd()
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index c11737b82..6013b656f 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -819,9 +819,12 @@ class LvmBug(RuntimeError):
 
 
 class LvmDebugData:
-	def __init__(self):
+	def __init__(self, do_collection):
 		self.fd = -1
 		self.fn = None
+		self.collect = do_collection
+		if self.collect:
+			log_msg("Collecting lvm debug data!")
 
 	def _remove_file(self):
 		if self.fn is not None:
@@ -835,8 +838,10 @@ class LvmDebugData:
 
 	def setup(self):
 		# Create a secure filename
-		self.fd, self.fn = tempfile.mkstemp(suffix=".log", prefix="lvmdbusd.lvm.debug.")
-		return self.fn
+		if self.collect:
+			self.fd, self.fn = tempfile.mkstemp(suffix=".log", prefix="lvmdbusd.lvm.debug.")
+			return self.fn
+		return None
 
 	def lvm_complete(self):
 		# Remove the file ASAP, so we decrease our odds of leaving it

