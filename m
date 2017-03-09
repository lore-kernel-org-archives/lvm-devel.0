From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:42:16 -0500
Subject: master - lvmdbusd: Simplify add_no_notify for loop
Message-ID: <201703092242.v29MgGCj014330@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=957e283de8298e2bb83517dbf8b724bc733cbbd9
Commit:        957e283de8298e2bb83517dbf8b724bc733cbbd9
Parent:        075f8e658c33400ceaa8ff40b261fe31f69eb825
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 16:06:00 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbusd: Simplify add_no_notify for loop

---
 daemons/lvmdbusd/utils.py |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 42dd7e5..2e7b808 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -514,8 +514,8 @@ def add_no_notify(cmdline):
 		return cmdline
 
 	if '--config' in cmdline:
-		for i in range(0, len(cmdline)):
-			if cmdline[i] == '--config':
+		for i, arg in enumerate(cmdline):
+			if arg == '--config':
 				cmdline[i] += "global/notify_dbus=0"
 				break
 	else:


