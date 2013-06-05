From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:37 +0000 (UTC)
Subject: dev-mornfall-lvmcache - WHATS_NEW: bad day
Message-ID: <20130605120337.10C876116D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3b551a93ed4dc85fc92897ce356baba1ca13a11
Commit:        b3b551a93ed4dc85fc92897ce356baba1ca13a11
Parent:        cb0d817fb56792e7d763d97cdf53e7444c447fdf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 16 11:02:18 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu May 16 11:02:38 2013 +0200

WHATS_NEW: bad day

---
 WHATS_NEW |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 528e1c2..c00597e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Refuse to init a snapshot merge in lvconvert if there's no kernel support.
   Fix exported symbols regex for non-GNU busybox sed.
   Accept --yes in all commands so test scripts can be simpler.
   Fix alignment of PV data area if detected alignment less than 1 MB (2.02.74).
@@ -1368,7 +1369,6 @@ Version 2.02.58 - 14th January 2010
 
 Version 2.02.57 - 12th January 2010
 ===================================
-  Refuse to init a snapshot merge in lvconvert if there's no kernel support.
   Ensure exactly one process returns from poll_daemon(), never two.
   Reset _vgs_locked in lvmcache_init() in child after forking.
   Define {DM, LVM}_UDEV_DISABLE_CHECKING=1 environment variables during tests.


