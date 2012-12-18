From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 18 Dec 2012 11:14:51 +0000 (UTC)
Subject: master - WHATS_NEW: changelog for fae1a611d2 and 5294a6f77a
Message-ID: <20121218111451.8B4BC1F3E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0379c480e09f0d6e8641bd4d8ca49a8bd3c32943
Commit:        0379c480e09f0d6e8641bd4d8ca49a8bd3c32943
Parent:        86e528c6677b4eff40df5c2424fdb588effdc73e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 18 12:12:58 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 18 12:12:58 2012 +0100

WHATS_NEW: changelog for fae1a611d2 and 5294a6f77a

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 106bee4..c18f3f4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.99 - 
 ===================================
+  Fix possible race while removing metadata from lvmetad.
+  Fix possible deadlock when querying and updating lvmetad at the same time.
   Check lvmcache_info_from_pvid and recall only when needed in _pv_read.
   Check for memory failure of dm_config_write_node() in lvmetad.
   Fix socket leak on error path in lvmetad's handle_connect.


