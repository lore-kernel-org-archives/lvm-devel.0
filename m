From: okozina <okozina@fedoraproject.org>
Date: Tue,  5 May 2015 18:54:21 +0000 (UTC)
Subject: master - WHATS_NEW: update for recent changes
Message-ID: <20150505185421.DC84660ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9fc6b654f55dfe0d6c1a7fc214f9d35cb505be11
Commit:        9fc6b654f55dfe0d6c1a7fc214f9d35cb505be11
Parent:        7fca7f196d17add08cdcc22ede99e8432a2fc4d0
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 5 19:35:52 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 5 20:52:49 2015 +0200

WHATS_NEW: update for recent changes

commits:
- bda26acf70e92232b1ed644dba6b44ecbff2a058
- 76a0dffe6f4869de9ca457119c9d7ced837d4e0b
---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5956b74..94851aa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.120 -
 ===============================
+  Refactor polldaemon interfaces to poll every operation by VG/LV couple
+  Skip wait after testing in _wait_for_single_lv when polling finished
   lvm2app closes locking on lvm_quit().
   Configure detects /run or /var/run.
   Add missing newline in clvmd --help output.


