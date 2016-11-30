From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 21:59:38 +0000 (UTC)
Subject: master - lvmdbusd: Supress protected member access warning
Message-ID: <20161130215938.177FE6096F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37f05ccab1a576bdd71be1f4f80ab6f621042d71
Commit:        37f05ccab1a576bdd71be1f4f80ab6f621042d71
Parent:        3bc69cb23c29e8e016282508514ce191c756b89c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 30 12:59:46 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 15:59:06 2016 -0600

lvmdbusd: Supress protected member access warning

We want _run to be protected so that users outside of the class
don't mistakenly use it.  It's for internal use only.
---
 daemons/lvmdbusd/utils.py |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 561b158..abee659 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -525,6 +525,7 @@ class MThreadRunner(object):
 
 	@staticmethod
 	def runner(obj):
+		# noinspection PyProtectedMember
 		obj._run()
 		with obj.cond:
 			obj.function_complete = True


