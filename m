From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 11 Jul 2014 12:10:41 +0000 (UTC)
Subject: master - WHATS_NEW: recent commits
Message-ID: <20140711121041.085AA6100C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17b92001ea4093e01d93ebd3645aa935896b9940
Commit:        17b92001ea4093e01d93ebd3645aa935896b9940
Parent:        7913f64a020db49cf2715d64982571d035ced893
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 11 14:09:05 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 11 14:09:05 2014 +0200

WHATS_NEW: recent commits

Commits:
d169ff1e039ecdfb1efac0a6464ca149d71d8767
bccc2bef33af081264bbc356e37efe89ef78b796
f76879ba440aa93f2e237335fe2cca6951a636bf
---
 WHATS_NEW |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a81fddb..db78347 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.108 -
 =================================
+  Add report/list_item_separator lvm.conf option.
+  Add lv_active_{locally,remotely,exclusively} LV reporting fields.
+  Comment out devices/{preferred_names,filter} in default lvm.conf file.
   Enhance lvconvert thin, thinpool, cache and cachepool command line support.
   Display 'C' only for cache and cache-pool target types in lvs.
   Prompt for confirmation before change LV into a snapshot exception store.


