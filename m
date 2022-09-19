From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:53 +0000 (GMT)
Subject: main - lvmdbusd: Add SIGUSR2 to dump flight recorder
Message-ID: <20220919155753.566063858C56@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3d8366ff21ee69380ab5fbca48204212a64a0cd
Commit:        b3d8366ff21ee69380ab5fbca48204212a64a0cd
Parent:        05f7fa5a8536d37b6a711ac0baab5bfd105bb0cc
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 9 17:44:10 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbusd: Add SIGUSR2 to dump flight recorder

---
 daemons/lvmdbusd/main.py  | 1 +
 daemons/lvmdbusd/utils.py | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 7b455052e..5e6f72cdc 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -77,6 +77,7 @@ def install_signal_handlers():
 		signal_add(GLib.PRIORITY_HIGH, signal.SIGHUP, utils.handler, signal.SIGHUP)
 		signal_add(GLib.PRIORITY_HIGH, signal.SIGINT, utils.handler, signal.SIGINT)
 		signal_add(GLib.PRIORITY_HIGH, signal.SIGUSR1, utils.handler, signal.SIGUSR1)
+		signal_add(GLib.PRIORITY_HIGH, signal.SIGUSR2, utils.handler, signal.SIGUSR2)
 	else:
 		log_error("GLib.unix_signal_[add|add_full] are NOT available!")
 
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index d24a34935..a10fa7864 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -346,8 +346,12 @@ def dump_threads_stackframe():
 # noinspection PyUnusedLocal
 def handler(signum):
 	try:
+		# signal 10
 		if signum == signal.SIGUSR1:
 			dump_threads_stackframe()
+		# signal 12
+		elif signum == signal.SIGUSR2:
+			cfg.blackbox.dump()
 		else:
 			cfg.run.value = 0
 			log_debug('Exiting daemon with signal %d' % signum)

