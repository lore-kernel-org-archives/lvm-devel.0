From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  6 Aug 2013 12:03:49 +0000 (UTC)
Subject: master - WHATS_NEW: previous commit
Message-ID: <20130806120349.40CFD61190@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=61e7dc833cbcc07453d0e919d52d92290d3ab541
Commit:        61e7dc833cbcc07453d0e919d52d92290d3ab541
Parent:        34d207d9b37edc2499dfff2c4809fecf72926416
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 6 14:03:43 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 6 14:03:43 2013 +0200

WHATS_NEW: previous commit

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b289bf2..5baa00d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Fix metadata area offset/size overflow if it's >= 4g and while using lvmetad.
   Inherit and apply any profile attached to a VG if creating new thin pool.
   Add initial support thin pool lvconvert --repair.
   Add --with-thin-repair and --with-thin-dump configure options.


