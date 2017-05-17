From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 17 May 2017 09:37:50 -0400
Subject: master - lvmdbusd: Fix notify_dbus mangling config option
Message-ID: <201705171337.v4HDboCt002118@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=16c6d9f11ab581a79fb57fd36142af1dc57a3c61
Commit:        16c6d9f11ab581a79fb57fd36142af1dc57a3c61
Parent:        9291fb7bf5d5f6265f3fd2f5ec6eff6542d2afb9
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed May 17 15:26:05 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed May 17 15:35:20 2017 +0200

lvmdbusd: Fix notify_dbus mangling config option

If config option is passed by caller, dbusd appends to the option not to
the value, and also without using delimiter.

Bug: RHBZ#1451612
---
 daemons/lvmdbusd/utils.py |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index af9e10a..170824d 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -519,7 +519,9 @@ def add_no_notify(cmdline):
 		if '--config' in cmdline:
 			for i, arg in enumerate(cmdline):
 				if arg == '--config':
-					cmdline[i] += "global/notify_dbus=0"
+					if len(cmdline) <= i+1:
+						raise dbus.exceptions.DBusException("Missing value for --config option.")
+					cmdline[i+1] += " global/notify_dbus=0"
 					break
 		else:
 			cmdline.extend(['--config', 'global/notify_dbus=0'])


