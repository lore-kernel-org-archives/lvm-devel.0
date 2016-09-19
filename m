From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 19 Sep 2016 20:38:25 +0000 (UTC)
Subject: master - lvmdbusd: Set value to non none on error
Message-ID: <20160919203825.3ABF860D98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5366e87574cbf9f13badea37b827ae5b97bcfdbf
Commit:        5366e87574cbf9f13badea37b827ae5b97bcfdbf
Parent:        65f59184c833584e96dd61030db495d33a3e7a4c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Sat Sep 17 00:10:46 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Sep 19 15:31:04 2016 -0500

lvmdbusd: Set value to non none on error

When we register a failure we need to use a valid value which will be
returned with the object manager.  Otherwise we will raise an Exception
because we are trying to construct an object path from None.
---
 daemons/lvmdbusd/request.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index ce6a6ef..c48d043 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -131,7 +131,7 @@ class RequestEntry(object):
 				self._job = None
 
 	def register_error(self, error_rc, error_message, error_exception):
-		self._reg_ending(None, error_rc, error_message, error_exception)
+		self._reg_ending('/', error_rc, error_message, error_exception)
 
 	def register_result(self, result):
 		self._reg_ending(result)


