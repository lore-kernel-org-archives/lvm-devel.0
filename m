From: David Teigland <teigland@sourceware.org>
Date: Tue, 3 Sep 2019 11:09:17 -0400
Subject: master - vgextend: check missing device during block size check
Message-ID: <201909031509.x83F9HT0013822@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=98d420200e16b450b6b7e33b83bdf36a59196d6d
Commit:        98d420200e16b450b6b7e33b83bdf36a59196d6d
Parent:        7cfbf3a394c2663fbeed17705320b83e69781720
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 3 10:07:56 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 3 10:07:56 2019 -0500

vgextend: check missing device during block size check

Checking the block size when a device is missing could
trigger a segfault.
---
 lib/metadata/metadata.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6d21ff9..61906cc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -769,6 +769,9 @@ int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 		logical_block_size = 0;
 		physical_block_size = 0;
 
+		if (!pvl->pv->dev)
+			continue;
+
 		if (!dev_get_direct_block_sizes(pvl->pv->dev, &physical_block_size, &logical_block_size))
 			continue;
 


