From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 28 Jun 2012 23:55:49 +0000 (UTC)
Subject: master - WHATS_NEW: update
Message-ID: <20120628235549.0E5941719@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f201d0e5e2149455709efa8bb977bd612694a5e
Commit:        2f201d0e5e2149455709efa8bb977bd612694a5e
Parent:        2d5adc5823353cba2bd3e585bb75a4a298f4cbfd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jun 28 23:14:27 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jun 28 23:14:27 2012 +0100

WHATS_NEW: update

Update WHATS_NEW.
---
 WHATS_NEW |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4a6df08..71c8219 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -2,10 +2,7 @@ Version 2.02.97 -
 ===============================
   Use vgchange -aay instead of vgchange -ay in clmvd init script.
   Add activation/auto_activation_volume_list to lvm.conf.
-  Add --activate ay to lvcreate.
-  Add --activate ay to lvchange.
-  Add --activate ay to pvscan.
-  Add --activate ay to vgchange.
+  Add --activate ay to lvcreate, lvchange, pvscan and vgchange.
   Add support for volume autoactivation using lvmetad.
   Add --activate synonym for --available arg and prefer --activate.
   Never issue discards when LV extents are being reconfigured, not deleted.


