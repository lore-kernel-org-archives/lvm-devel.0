From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 20:00:21 +0000 (UTC)
Subject: master - lvmdbusd: Fix source documentation
Message-ID: <20161117200021.914FD602FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b4c5a2151a3a121123a0e4d5b9fd20344979a23
Commit:        3b4c5a2151a3a121123a0e4d5b9fd20344979a23
Parent:        3a6c78e22aa958254f7ff993329cac3d7202d290
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Nov 17 13:58:17 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 13:58:17 2016 -0600

lvmdbusd: Fix source documentation

---
 daemons/lvmdbusd/manager.py |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index bdb08f6..3f6f09b 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -170,6 +170,8 @@ class Manager(AutomatedProperties):
 		"""
 		Allow the client to enable/disable lvm shell, used for testing
 		:param yes_no:
+		:param cb:	dbus python call back parameter, not client visible
+		:param cbe:	dbus python error call back parameter, not client visible
 		:return: Nothing
 		"""
 		r = RequestEntry(-1, Manager._use_lvm_shell, (yes_no,), cb, cbe, False)


