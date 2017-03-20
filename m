From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 20 Mar 2017 11:11:04 -0400
Subject: master - lvmdbusd: Rename ee to got_external_event
Message-ID: <201703201511.v2KFB4LC025725@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=862ca6e8b7754b249e989dba934c32170d8074b9
Commit:        862ca6e8b7754b249e989dba934c32170d8074b9
Parent:        b65a9230a359de82cb4b5b2e802a493b72d46c4f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Mar 20 09:43:34 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 20 10:08:39 2017 -0500

lvmdbusd: Rename ee to got_external_event

This variable is global, make it more descriptive.
---
 daemons/lvmdbusd/cfg.py     |    2 +-
 daemons/lvmdbusd/manager.py |    2 +-
 daemons/lvmdbusd/utils.py   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index f3eadf1..771909f 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -26,7 +26,7 @@ bus = None
 args = None
 
 # Set to true if we are depending on external events for updates
-ee = False
+got_external_event = False
 
 # Shared state variable across all processes
 run = multiprocessing.Value('i', 1)
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 433473f..5bcdbb8 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -206,7 +206,7 @@ class Manager(AutomatedProperties):
 				utils.log_debug("ExternalEvent received, disabling "
 								"udev monitoring")
 				# We are dependent on external events now to stay current!
-				cfg.ee = True
+				cfg.got_external_event = True
 
 		r = RequestEntry(
 			-1, Manager._external_event, (command,), None, None, False)
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index c9a84cc..af9e10a 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -512,7 +512,7 @@ def add_no_notify(cmdline):
 
 	# Only after we have seen an external event will be disable lvm from sending
 	# us one when we call lvm
-	if cfg.ee:
+	if cfg.got_external_event:
 		if 'help' in cmdline:
 			return cmdline
 


