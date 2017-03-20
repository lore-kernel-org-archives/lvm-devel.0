From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 20 Mar 2017 11:10:51 -0400
Subject: master - lvmdbusd: Only disable notify_dbus after getting external event
Message-ID: <201703201510.v2KFAp65025686@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2dc71fc291b3ac861298b4dd7b25963dd9325a4d
Commit:        2dc71fc291b3ac861298b4dd7b25963dd9325a4d
Parent:        17b56a4aed90806eac03c32f013f552440b2f596
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 15 10:57:01 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 20 10:08:38 2017 -0500

lvmdbusd: Only disable notify_dbus after getting external event

If we always disable the sending of notify dbus events then in the case
where all the users are lvm dbus users we will be in udev handling mode
until at least 1 external lvm command occurs.  Instead we will not disable
notify dbus until after we get at least 1 external event.  This makes the
service get into the correct mode of operation faster.
---
 daemons/lvmdbusd/utils.py |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 2e7b808..c9a84cc 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -510,16 +510,19 @@ def add_no_notify(cmdline):
 	:rtype: list
 	"""
 
-	if 'help' in cmdline:
-		return cmdline
-
-	if '--config' in cmdline:
-		for i, arg in enumerate(cmdline):
-			if arg == '--config':
-				cmdline[i] += "global/notify_dbus=0"
-				break
-	else:
-		cmdline.extend(['--config', 'global/notify_dbus=0'])
+	# Only after we have seen an external event will be disable lvm from sending
+	# us one when we call lvm
+	if cfg.ee:
+		if 'help' in cmdline:
+			return cmdline
+
+		if '--config' in cmdline:
+			for i, arg in enumerate(cmdline):
+				if arg == '--config':
+					cmdline[i] += "global/notify_dbus=0"
+					break
+		else:
+			cmdline.extend(['--config', 'global/notify_dbus=0'])
 	return cmdline
 
 


