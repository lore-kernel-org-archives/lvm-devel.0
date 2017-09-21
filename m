From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 21 Sep 2017 15:36:59 -0400
Subject: master - lvmdbusd: Improve args comparison
Message-ID: <201709211936.v8LJax6x015569@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bdccab07f94f6b2e464e2d43d1f91dbb0a9fb2e0
Commit:        bdccab07f94f6b2e464e2d43d1f91dbb0a9fb2e0
Parent:        7a6e438df8d3e2bb83723d707048e4431016d84a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 21 09:22:07 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Sep 21 14:35:36 2017 -0500

lvmdbusd: Improve args comparison

---
 daemons/lvmdbusd/utils.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 98fd017..c9fbaad 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -584,7 +584,7 @@ class MThreadRunner(object):
 
 	def _run(self):
 		try:
-			if len(self.args):
+			if self.args:
 				self.rc = self.f(*self.args)
 			else:
 				self.rc = self.f()


