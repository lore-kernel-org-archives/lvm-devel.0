From: Tony Asleson <tasleson@sourceware.org>
Date: Tue, 20 Sep 2022 21:38:11 +0000 (GMT)
Subject: main - lvmdbusd: Register for SIGTERM
Message-ID: <20220920213811.6BDA63858C2F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c2ed7422105c59446c4d8a894c87feb37c5de7a
Commit:        9c2ed7422105c59446c4d8a894c87feb37c5de7a
Parent:        d88998f5163f84aa7305edfeb9ec51dc5b0c6733
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Sep 20 14:28:57 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Sep 20 16:37:01 2022 -0500

lvmdbusd: Register for SIGTERM

Ensure we log that we are exiting on this signal too.
---
 daemons/lvmdbusd/main.py | 1 +
 1 file changed, 1 insertion(+)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index ac309aa69..e4531526c 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -80,6 +80,7 @@ def install_signal_handlers():
 		signal_add(GLib.PRIORITY_HIGH, signal.SIGINT, utils.handler, signal.SIGINT)
 		signal_add(GLib.PRIORITY_HIGH, signal.SIGUSR1, utils.handler, signal.SIGUSR1)
 		signal_add(GLib.PRIORITY_HIGH, signal.SIGUSR2, utils.handler, signal.SIGUSR2)
+		signal_add(GLib.PRIORITY_HIGH, signal.SIGTERM, utils.handler, signal.SIGTERM)
 	else:
 		log_error("GLib.unix_signal_[add|add_full] are NOT available!")
 

