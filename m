From: Tony Asleson <tasleson@sourceware.org>
Date: Fri,  3 Mar 2023 18:03:25 +0000 (GMT)
Subject: main - lvmdbusd: Remove unused import
Message-ID: <20230303180325.339EE3858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4cbe789f9c273cd03a3b0aff39aa43fc7674099f
Commit:        4cbe789f9c273cd03a3b0aff39aa43fc7674099f
Parent:        b0e75bd356a070423754676872b7b6948913be2e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Feb 27 09:57:18 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Feb 27 09:57:18 2023 -0600

lvmdbusd: Remove unused import

---
 daemons/lvmdbusd/objectmanager.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index c5ea14bc3..ed62feb42 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -13,7 +13,7 @@ import dbus
 import os
 import copy
 from . import cfg
-from .utils import log_debug, pv_obj_path_generate, log_error, extract_stack_trace
+from .utils import log_debug, log_error, extract_stack_trace
 from .automatedproperties import AutomatedProperties
 
 

