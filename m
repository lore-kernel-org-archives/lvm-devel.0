From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:31 +0000 (UTC)
Subject: dev-mornfall-activate - WHATS_NEW: for commit 4f6c2951d6495ee335ab69da44ae2647cd341276
Message-ID: <20130604192631.44FCD60D78@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb0d817fb56792e7d763d97cdf53e7444c447fdf
Commit:        cb0d817fb56792e7d763d97cdf53e7444c447fdf
Parent:        4777eb68728859a0b3651e29c628111ed7c99103
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 16 08:38:27 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu May 16 08:38:27 2013 +0200

WHATS_NEW: for commit 4f6c2951d6495ee335ab69da44ae2647cd341276

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aa1a1c0..528e1c2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1368,6 +1368,7 @@ Version 2.02.58 - 14th January 2010
 
 Version 2.02.57 - 12th January 2010
 ===================================
+  Refuse to init a snapshot merge in lvconvert if there's no kernel support.
   Ensure exactly one process returns from poll_daemon(), never two.
   Reset _vgs_locked in lvmcache_init() in child after forking.
   Define {DM, LVM}_UDEV_DISABLE_CHECKING=1 environment variables during tests.


