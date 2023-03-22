From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 22 Mar 2023 03:42:52 +0000 (GMT)
Subject: main - Fix import of utils from lvmdbusd.cfg
Message-ID: <20230322034252.D08333858D38@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6f8f59239c65a7f1f9be1d24bf9ba02cfee5b0e
Commit:        d6f8f59239c65a7f1f9be1d24bf9ba02cfee5b0e
Parent:        238e3777777e1e75b388d8e05f9c1212aa4d1eed
Author:        Adam Williamson <awilliam@redhat.com>
AuthorDate:    Tue Mar 21 11:46:54 2023 -0700
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Mar 21 22:42:25 2023 -0500

Fix import of utils from lvmdbusd.cfg

Signed-off-by: Adam Williamson <awilliam@redhat.com>
---
 daemons/lvmdbusd/cfg.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 9da4b1267..9f4360100 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -11,7 +11,7 @@ import os
 import multiprocessing
 import queue
 import itertools
-from utils import LvmDebugData
+from lvmdbusd.utils import LvmDebugData
 
 from lvmdbusd import path
 

