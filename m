From: Tony Asleson <tasleson@sourceware.org>
Date: Thu,  6 Aug 2020 20:44:15 +0000 (GMT)
Subject: master - lvmdbusd: Bump LVM DBus API version
Message-ID: <20200806204415.6DB613857C40@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d4d060acd5e35ca052dd4ba0743732ed4fb46f86
Commit:        d4d060acd5e35ca052dd4ba0743732ed4fb46f86
Parent:        8f1068c02d06e9104c47db0131617c8f98d31718
Author:        Vojtech Trefny <vtrefny@redhat.com>
AuthorDate:    Wed Jul 1 13:27:47 2020 +0200
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Aug 6 13:54:45 2020 -0500

lvmdbusd: Bump LVM DBus API version

So users can check for writecache support.
---
 daemons/lvmdbusd/manager.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 2857e9a10..573a3966f 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -27,7 +27,7 @@ class Manager(AutomatedProperties):
 
 	@property
 	def Version(self):
-		return dbus.String('1.0.0')
+		return dbus.String('1.1.0')
 
 	@staticmethod
 	def handle_execute(rc, out, err):


