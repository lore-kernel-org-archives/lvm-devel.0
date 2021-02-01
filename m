From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:39 +0000 (GMT)
Subject: main - wipe: reformat message for failure case
Message-ID: <20210201114739.9ED0A3836C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3acf6040b558a121d918a478859ae0c97a679047
Commit:        3acf6040b558a121d918a478859ae0c97a679047
Parent:        8f5695fa71e0b293e774cfbaf7af7985896cd47a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 19:21:55 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:13:49 2021 +0100

wipe: reformat message for failure case

Use the same error message layout to match BLKZEROUT look.
Makes testing easier.
---
 lib/metadata/lv_manip.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c82038269..d101fa582 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7785,10 +7785,10 @@ retry_with_dev_set:
 #endif
 		if (!dev_set_bytes(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp.zero_value)) {
 			sigint_restore();
-			log_error("%s %s of logical volume %s with value %d.",
+			log_error("%s logical volume %s with value %d and size %s.",
 				  sigint_caught() ? "Interrupted initialization" : "Failed to initialize",
-				  display_size(lv->vg->cmd, zero_sectors),
-				  display_lvname(lv), wp.zero_value);
+				  display_lvname(lv), wp.zero_value,
+				  display_size(lv->vg->cmd, zero_sectors));
 			return 0;
 		}
 	}


