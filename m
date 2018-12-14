From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 14 Dec 2018 09:31:01 -0500
Subject: master - lvmdbusd: Dump blackbox newest first
Message-ID: <201812141431.wBEEV1iJ011959@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1684bf8e89b87d7f04e0a963def66f76634766d
Commit:        f1684bf8e89b87d7f04e0a963def66f76634766d
Parent:        859feb81e5b61ac2109b1d7850844ccf1ce3e5bf
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Dec 11 13:58:23 2018 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Dec 14 08:28:02 2018 -0600

lvmdbusd: Dump blackbox newest first

When we get bug reports we may not get the entire log, so lets
dump the fight recorder from newest to oldest as the one we
are interested in was likely to be the last command run.
---
 daemons/lvmdbusd/cmdhandler.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 4fb1670..a9177c5 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -67,7 +67,7 @@ class LvmFlightRecorder(object):
 		with cmd_lock:
 			if len(self.queue):
 				log_error("LVM dbus flight recorder START")
-				for c in self.queue:
+				for c in reversed(self.queue):
 					log_error(str(c))
 				log_error("LVM dbus flight recorder END")
 


