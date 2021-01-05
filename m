From: David Teigland <teigland@sourceware.org>
Date: Tue,  5 Jan 2021 16:20:09 +0000 (GMT)
Subject: stable-2.02 - vgextend: check missing device during block size check
Message-ID: <20210105162009.13A563857801@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b98c3346350b7c270140c1f21fda0436876e16e8
Commit:        b98c3346350b7c270140c1f21fda0436876e16e8
Parent:        92a67e3d3f84825c7be92d0d2259fa92b56092b9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 3 10:07:56 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 5 10:19:01 2021 -0600

vgextend: check missing device during block size check

Checking the block size when a device is missing could
trigger a segfault.
---
 lib/metadata/metadata.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index fd10a02da..6c4683aa3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -718,6 +718,9 @@ int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 		logical_block_size = 0;
 		physical_block_size = 0;
 
+		if (!pvl->pv->dev)
+			continue;
+
 		if (!dev_get_direct_block_sizes(pvl->pv->dev, &physical_block_size, &logical_block_size))
 			continue;
 


