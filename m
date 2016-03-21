From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 21 Mar 2016 22:34:04 +0000 (UTC)
Subject: master - lvmdbusd: Change print statements to log_error
Message-ID: <20160321223404.1D39D6072A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16b127259761da212bc7ba6ab3c95b42fe0fe276
Commit:        16b127259761da212bc7ba6ab3c95b42fe0fe276
Parent:        ca28ea88bedbc0ecb64e5579c1b3076b9a7cd533
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Mar 21 17:24:04 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 21 17:28:51 2016 -0500

lvmdbusd: Change print statements to log_error

Should not be using print() in the service code.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/lvmdb.py |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index be37868..d14ae3b 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -16,7 +16,7 @@ import os
 
 try:
 	from . import cmdhandler
-	from .utils import log_debug
+	from .utils import log_debug, log_error
 except SystemError:
 	import cmdhandler
 	from utils import log_debug
@@ -337,13 +337,13 @@ class DataStore(object):
 					rc.append(self.lvs[self.lv_full_name_to_uuid[s]])
 				return rc
 		except KeyError as ke:
-			print("Key %s not found!" % (str(lv_names)))
-			print("lv name to uuid lookup")
+			log_error("Key %s not found!" % (str(lv_names)))
+			log_error("lv name to uuid lookup")
 			for keys in sorted(self.lv_full_name_to_uuid.keys()):
-				print("%s" % (keys))
-			print("lvs entries by uuid")
+				log_error("%s" % (keys))
+			log_error("lvs entries by uuid")
 			for keys in sorted(self.lvs.keys()):
-				print("%s" % (keys))
+				log_error("%s" % (keys))
 			raise ke
 
 	def pv_pe_segments(self, pv_uuid):


