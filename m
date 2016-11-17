From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 20:00:19 +0000 (UTC)
Subject: master - lvmdbusd: cmdhandler.py, fix imports
Message-ID: <20161117200019.6AF84602FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a6c78e22aa958254f7ff993329cac3d7202d290
Commit:        3a6c78e22aa958254f7ff993329cac3d7202d290
Parent:        19a0bf9df61d2ad58cc1be70cf6132b57cb49c85
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Nov 17 13:57:44 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 13:57:44 2016 -0600

lvmdbusd: cmdhandler.py, fix imports

Use the correct py3 syntax for handling imports.  Also use print instead
of log_debug which in this context will produce no output.
---
 daemons/lvmdbusd/cmdhandler.py |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index dff91ad..1d5ff4a 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -15,14 +15,9 @@ import collections
 import traceback
 import os
 
-try:
-	from . import cfg
-	from .utils import pv_dest_ranges, log_debug, log_error
-	from .lvm_shell_proxy import LVMShellProxy
-except SystemError:
-	import cfg
-	from utils import pv_dest_ranges, log_debug, log_error
-	from lvm_shell_proxy import LVMShellProxy
+from lvmdbusd import cfg
+from lvmdbusd.utils import pv_dest_ranges, log_debug, log_error
+from lvmdbusd.lvm_shell_proxy import LVMShellProxy
 
 try:
 	import simplejson as json
@@ -117,6 +112,7 @@ _t_call = call_lvm
 
 def _shell_cfg():
 	global _t_call
+	# noinspection PyBroadException
 	try:
 		lvm_shell = LVMShellProxy()
 		_t_call = lvm_shell.call_lvm
@@ -750,4 +746,4 @@ if __name__ == '__main__':
 	pv_data = pv_retrieve_with_segs()
 
 	for p in pv_data:
-		log_debug(str(p))
+		print(str(p))


