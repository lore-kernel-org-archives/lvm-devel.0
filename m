From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 Aug 2018 14:41:38 -0400
Subject: master - config: improve use_blkid_wiping
Message-ID: <201808211841.w7LIfcnj027050@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=10ede2cc0fdabaeb19c5b5b3341164432f6d4425
Commit:        10ede2cc0fdabaeb19c5b5b3341164432f6d4425
Parent:        4578411633a40c8c9068ff439ef3c33cbe78d25a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 21 12:24:35 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Aug 21 12:24:35 2018 -0500

config: improve use_blkid_wiping

mention that libblkid is used to both detect
and erase signatures.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7882e95..1d0cc79 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -471,7 +471,7 @@ cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0,
 	"and revert to the previous algorithm.\n")
 
 cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_BLKID_WIPING, vsn(2, 2, 105), "@DEFAULT_USE_BLKID_WIPING@", 0, NULL,
-	"Use blkid to detect existing signatures on new PVs and LVs.\n"
+	"Use blkid to detect and erase existing signatures on new PVs and LVs.\n"
 	"The blkid library can detect more signatures than the native LVM\n"
 	"detection code, but may take longer. LVM needs to be compiled with\n"
 	"blkid wiping support for this setting to apply. LVM native detection\n"


