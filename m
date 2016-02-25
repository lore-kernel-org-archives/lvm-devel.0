From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:44:33 +0000 (UTC)
Subject: master - lvmdbusd: Do only 1 refresh for Vg.Change()
Message-ID: <20160225224433.2246D602C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=081359f6cd2ed8224992c91e99617ef576e01488
Commit:        081359f6cd2ed8224992c91e99617ef576e01488
Parent:        26b826ccf59b891a7947d9f7f2bacf8d0a5172a9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Feb 25 16:34:51 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Feb 25 16:43:56 2016 -0600

lvmdbusd: Do only 1 refresh for Vg.Change()

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/vg.py |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index b39f703..f5b3e45 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -237,10 +237,7 @@ class Vg(AutomatedProperties):
 			# locals(), ['Variant']).Variant("s", "n")}
 
 			if rc == 0:
-				dbo.refresh()
-
-				if (('activate' in change_options) or ('-a' in change_options)):
-					cfg.load()
+				cfg.load()
 			else:
 				raise dbus.exceptions.DBusException(
 					VG_INTERFACE,


