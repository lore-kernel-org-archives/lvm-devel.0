From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Nov 2022 11:41:40 +0000 (GMT)
Subject: main - vdo: improve validation message
Message-ID: <20221108114140.B7DDE38582A1@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=403779333be419352d6062da592ea78e6096e12b
Commit:        403779333be419352d6062da592ea78e6096e12b
Parent:        b9f35e07db41f3dd6bea2c91a8bc1bff93a4d406
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 8 12:40:21 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 8 12:40:21 2022 +0100

vdo: improve validation message

Rephrase.
---
 device_mapper/vdo/vdo_target.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/device_mapper/vdo/vdo_target.c b/device_mapper/vdo/vdo_target.c
index ab3fff26a..a8a753e39 100644
--- a/device_mapper/vdo/vdo_target.c
+++ b/device_mapper/vdo/vdo_target.c
@@ -156,9 +156,9 @@ bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 	}
 
 	if (vdo_size > DM_VDO_LOGICAL_SIZE_MAXIMUM) {
-		log_error("VDO logical size is by " FMTu64 "KiB bigger then limit " FMTu64 "TiB.",
-			  (vdo_size - DM_VDO_LOGICAL_SIZE_MAXIMUM) / 2,
-			  DM_VDO_LOGICAL_SIZE_MAXIMUM / (UINT64_C(1024) * 1024 * 1024 * 1024 >> SECTOR_SHIFT));
+		log_error("VDO logical size is larger than limit " FMTu64 " TiB by " FMTu64 " KiB.",
+			  DM_VDO_LOGICAL_SIZE_MAXIMUM / (UINT64_C(1024) * 1024 * 1024 * 1024 >> SECTOR_SHIFT),
+			  (vdo_size - DM_VDO_LOGICAL_SIZE_MAXIMUM) / 2);
 		valid = false;
 	}
 

