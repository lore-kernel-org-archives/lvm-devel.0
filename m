From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 16 Jan 2019 17:32:37 -0500
Subject: master - lvmdbusd: Ensure all paths return value
Message-ID: <201901162232.x0GMWb6P027509@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6d26245fbde5e66a616f27363118dc370062f7a
Commit:        b6d26245fbde5e66a616f27363118dc370062f7a
Parent:        5f102b3421873a6111e477b40fdbe1a93ef258b9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jan 14 09:08:55 2019 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Jan 16 16:29:05 2019 -0600

lvmdbusd: Ensure all paths return value

---
 daemons/lvmdbusd/automatedproperties.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/automatedproperties.py b/daemons/lvmdbusd/automatedproperties.py
index e188fa4..b591948 100644
--- a/daemons/lvmdbusd/automatedproperties.py
+++ b/daemons/lvmdbusd/automatedproperties.py
@@ -155,7 +155,7 @@ class AutomatedProperties(dbus.service.Object):
 		# through all dbus objects as some don't have a search method, like
 		# 'Manager' object.
 		if not self._ap_search_method:
-			return
+			return 0
 
 		search = self.lvm_id
 		if search_key:


