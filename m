From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:42:08 -0500
Subject: master - lvmdbusd: Correct utils.add_no_notify doc
Message-ID: <201703092242.v29Mg8RH012091@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=075f8e658c33400ceaa8ff40b261fe31f69eb825
Commit:        075f8e658c33400ceaa8ff40b261fe31f69eb825
Parent:        00143753ee4aec09eb40176ada5d34c3bde91884
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 16:04:24 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbusd: Correct utils.add_no_notify doc

---
 daemons/lvmdbusd/utils.py |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index bf2552c..42dd7e5 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -503,9 +503,11 @@ def add_no_notify(cmdline):
 	"""
 	Given a command line to execute we will see if `--config` is present, if it
 	is we will add the global/notify_dbus=0 to it, otherwise we will append it
-	to the end
-	:param cmdline:
+	to the end of the list.
+	:param: cmdline: The command line to inspect
+	:type: cmdline: list
 	:return: cmdline with notify_dbus config option present
+	:rtype: list
 	"""
 
 	if 'help' in cmdline:


