From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Nov 2014 12:27:48 +0000 (UTC)
Subject: master - WHATS_NEW: '_' -> ','
Message-ID: <20141111122748.BCF3660E4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7fa7ac528d1dbbcaf424b422a462af437bcf56fb
Commit:        7fa7ac528d1dbbcaf424b422a462af437bcf56fb
Parent:        2dde6c6531f9a06896ae61f0878745542b4001b6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 11 13:27:34 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 11 13:27:34 2014 +0100

WHATS_NEW: '_' -> ','

---
 WHATS_NEW |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3a3f7d5..a4f5c97 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.02.112 - 
 =====================================
-  Add cache_{read_write}_{hits,misses} reporting fields.
+  Add cache_{read,write}_{hits,misses} reporting fields.
   Add cache_{total,used,dirty}_blocks reporting fields.
   Add _corig as reserved suffix.
   Reduce vg write and vg commits when creating spare volumes.


