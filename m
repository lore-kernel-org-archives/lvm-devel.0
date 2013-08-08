From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  8 Aug 2013 08:05:16 +0000 (UTC)
Subject: master - WHATS_NEW: entry for 19baf84290186a550b212260144523266350252b
Message-ID: <20130808080516.434C9610AF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d3347f70be96558d830409770156b0a01815212
Commit:        8d3347f70be96558d830409770156b0a01815212
Parent:        68c2d352ec2746ab278856388c6203c604f6248a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 8 10:04:53 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 8 10:04:53 2013 +0200

WHATS_NEW: entry for 19baf84290186a550b212260144523266350252b

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index acab587..773312e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Verify clvmd message validity before processing and log error if incorrect.
   Fix issue preventing PV creation on mirror LVs
   When converting mirrors, default segtype should be the same unless specified.
   Make "raid1" the default mirror segment type.


