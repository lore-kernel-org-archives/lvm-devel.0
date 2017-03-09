From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:41:36 -0500
Subject: master - lvmdbusd: Correct src doc for Manager.UseLvmShell
Message-ID: <201703092241.v29Mfawo000336@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c0002d7659ef27fcb7c8cf21b6b86d62e955499
Commit:        0c0002d7659ef27fcb7c8cf21b6b86d62e955499
Parent:        11cfc58976df33b810e28c0b652274158d683131
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 8 15:37:08 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbusd: Correct src doc for Manager.UseLvmShell

It returns a boolean.
---
 daemons/lvmdbusd/manager.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 6d122ba..3c2bfcb 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -183,7 +183,7 @@ class Manager(AutomatedProperties):
 		:param yes_no:
 		:param cb:	dbus python call back parameter, not client visible
 		:param cbe:	dbus python error call back parameter, not client visible
-		:return: Nothing
+		:return: Boolean
 		"""
 		r = RequestEntry(-1, Manager._use_lvm_shell, (yes_no,), cb, cbe, False)
 		cfg.worker_q.put(r)


