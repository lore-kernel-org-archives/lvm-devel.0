From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 13 Feb 2015 16:27:51 +0000 (UTC)
Subject: master - WHATS_NEW for system_id
Message-ID: <20150213162751.2078460D59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3f3878ffd2b8da9702865dc6d9ead9f11fdbb0e
Commit:        d3f3878ffd2b8da9702865dc6d9ead9f11fdbb0e
Parent:        8cdec4c434a8b043a2a0a44252bfd11f40b0a8ec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 13 10:27:17 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 13 10:27:17 2015 -0600

WHATS_NEW for system_id

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1aba0ac..0f62127 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Add support for VG system_id to control host access to VGs.
   Update vgextend to use process_each_vg.
   Add --ignoreskippedcluster to pvchange.
   Allow pvchange to modify several properties at once.


