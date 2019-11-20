From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Nov 2019 09:33:01 -0500
Subject: stable-2.02 - WHATS_NEW: update
Message-ID: <05208.119112009325601261@us-mta-312.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=26f94d91195531730c22eac26c741f1b4d2e0f1e
Commit:        26f94d91195531730c22eac26c741f1b4d2e0f1e
Parent:        9e45ad04b035468bc4ed7a68e654bfa5641f6b2c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Oct 23 09:32:36 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Nov 20 15:30:34 2019 +0100

WHATS_NEW: update

---
 WHATS_NEW    |    2 ++
 WHATS_NEW_DM |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 49c31a4..50fd519 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -3,6 +3,7 @@ Version 2.02.187 -
   Fix resize of thin-pool with data and metadata of different segtype.
   Fix splitting mirror leg in cluster.
   Fix activation order when removing merged snapshot.
+  Add support for DM_DEVICE_GET_TARGET_VERSION into device_mapper.
   Add lvextend-raid.sh to check on RaidLV extensions synchronization.
   Fix lvmetad shutdown and avoid lenghty timeouts when rebooting system.
   Prevent creating VGs with PVs with different logical block sizes.
@@ -10,6 +11,7 @@ Version 2.02.187 -
   Activate thin-pool layered volume as 'read-only' device.
   Ignore crypto devices with UUID signature CRYPT-SUBDEV.
   Enhance validation for thin and cache pool conversion and swapping.
+  Fixed activation on boot - lvm2 no longer activates incomplete VGs.
 
 Version 2.02.186 - 27th August 2019
 ===================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 576ad38..6a909c0 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.166 - 
 ===================================
+  Add support for DM_DEVICE_GET_TARGET_VERSION.
 
 Version 1.02.164 - 27th August 2019
 ===================================



