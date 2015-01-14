From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Jan 2015 14:15:49 +0000 (UTC)
Subject: master - WHATS_NEW
Message-ID: <20150114141549.E096360668@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a55175bacbad1261917f170254040fb2846f994
Commit:        4a55175bacbad1261917f170254040fb2846f994
Parent:        2908ab3eed4d7feb041c99a4e2fca98a5bcf6922
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 14 15:15:29 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 14 15:15:29 2015 +0100

WHATS_NEW

More news
---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3881d5d..344aeb7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.115 -
 =====================================
+  Report lv_health_status and health attribute also for thin pool.
+  Add lv_error_when_full reporting field.
   Add support for lvcreate --errorwhenfull y|n for thin pools.
   Fix lvconvert --repair to honour resilience requirement for segmented RAID LV.
   Filter out partitioned device-mapper devices as unsuitable for use as PVs.


