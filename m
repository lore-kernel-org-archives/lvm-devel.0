From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Jun 2016 21:06:35 +0000 (UTC)
Subject: master - lvmdbusd: Create correct LV object type
Message-ID: <20160610210635.B766160E6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cdf06044e189ec1adeaba101a21598c31752b9cd
Commit:        cdf06044e189ec1adeaba101a21598c31752b9cd
Parent:        b81186e535f0c93ef8b276cfb2b7bcf55268aec0
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 10 12:11:17 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 10 16:05:03 2016 -0500

lvmdbusd: Create correct LV object type

We were initially looking to see if an LV was hidden and if it was we were
creating an instance of a LvCommon object to represent it.  Thus if we
had a hidden cache pool for example we were missing the methods and
properties for the cache pool.  However, when we create the object path,
any hidden LVs, regardless of type/functionality will be placed in the
hidden path.
---
 daemons/lvmdbusd/lv.py |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index e32f8e5..5c7b3b5 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -176,8 +176,6 @@ class LvState(State):
 			self.Name, (self.Attr, self.layout, self.role))
 
 	def _object_type_create(self):
-		if self.Name[0] == '[':
-			return LvCommon
 		if self.Attr[0] == 't':
 			return LvThinPool
 		elif self.Attr[0] == 'C':
@@ -185,6 +183,8 @@ class LvState(State):
 				return LvCachePool
 			else:
 				return LvCacheLv
+		elif self.Name[0] == '[':
+			return LvCommon
 		elif self.OriginLv != '/':
 			return LvSnapShot
 		else:


