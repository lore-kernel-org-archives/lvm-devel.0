From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:00 +0000 (GMT)
Subject: main - lvmdbusd: Make sure to set cfg.got_external_event
Message-ID: <20220919155800.2569C3858C39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cfc87157a4fdec39c2b570bd35ce812cda3003f6
Commit:        cfc87157a4fdec39c2b570bd35ce812cda3003f6
Parent:        068073e924246ebda66b6dff590455d648007007
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 17 12:08:16 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Make sure to set cfg.got_external_event

We were incorrectly only setting this if --udev wasn't present on the
command line.  In all cases when we see a manager.ExternalEvent we want
to set this.
---
 daemons/lvmdbusd/manager.py | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index e6b0718c4..45e7bb0b8 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -194,6 +194,7 @@ class Manager(AutomatedProperties):
 	def _external_event(command):
 		utils.log_debug("Processing _external_event= %s" % command,
 							'bg_black', 'fg_orange')
+		cfg.got_external_event = True
 		cfg.load()
 
 	@dbus.service.method(
@@ -204,11 +205,9 @@ class Manager(AutomatedProperties):
 		# If a user didn't explicitly specify udev, we will turn it off now.
 		if not cfg.args.use_udev:
 			if udevwatch.remove():
-				utils.log_debug("ExternalEvent received, disabling "
+				utils.log_msg("ExternalEvent received, disabling "
 								"udev monitoring")
 				# We are dependent on external events now to stay current!
-				cfg.got_external_event = True
-
 		r = RequestEntry(
 			-1, Manager._external_event, (command,), None, None, False)
 		cfg.worker_q.put(r)

