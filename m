From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 30 Jan 2015 15:34:57 +0000 (UTC)
Subject: master - WHATS_NEW
Message-ID: <20150130153457.E4EBB614B8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04b60e927464454c376ac97d7285affbde186e2f
Commit:        04b60e927464454c376ac97d7285affbde186e2f
Parent:        40102ae01401741e007066373e8013f16c694f89
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 30 16:34:19 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 30 16:34:19 2015 +0100

WHATS_NEW

For thin fix.
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 45e01fb..b99ce31 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Deactivate unused thin pools activated with lvm2 pre 2.02.112 version.
   Check lock holding LV when lvconverting stacked raid LV in cluster.
   Support "udev" ext. dev. info for filters: PV min size, mpath, md, partition.
   Add fw_raid_component_detection lvm.conf option to enable FW raid detection.


