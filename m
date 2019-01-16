From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 16 Jan 2019 17:32:41 -0500
Subject: master - lvmdbusd: LookUpByLvmId: Add doc for cb, cbe
Message-ID: <201901162232.x0GMWfFD027520@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c1fd827748a0b5a1a2c3e54c5fdc0478b45515f
Commit:        4c1fd827748a0b5a1a2c3e54c5fdc0478b45515f
Parent:        b6d26245fbde5e66a616f27363118dc370062f7a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jan 14 09:10:24 2019 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Jan 16 16:29:05 2019 -0600

lvmdbusd: LookUpByLvmId: Add doc for cb, cbe

---
 daemons/lvmdbusd/manager.py |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index d77c7b4..8de05db 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -164,6 +164,8 @@ class Manager(AutomatedProperties):
 		return the object path in O(1) time.
 
 		:param key: The lookup value
+		:param cb:	dbus python call back parameter, not client visible
+		:param cbe:	dbus python error call back parameter, not client visible
 		:return: Return the object path.  If object not found you will get '/'
 		"""
 		r = RequestEntry(-1, Manager._lookup_by_lvm_id, (key,), cb, cbe, False)


