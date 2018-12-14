From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Dec 2018 09:17:50 -0500
Subject: master - debug: drop extra tracing
Message-ID: <201812141417.wBEEHoLm010366@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db6d9e04af7277a5e2883743e0a9a1502d97249f
Commit:        db6d9e04af7277a5e2883743e0a9a1502d97249f
Parent:        cc5cfb88d70ef7982e66e5ddf8a5fbd69d485fec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 1 21:39:42 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 15:14:48 2018 +0100

debug: drop extra tracing

Stack tracing after log_error() is not needed.
---
 device_mapper/libdm-deptree.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index c134489..7a7239e 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2742,7 +2742,7 @@ static int _vdo_emit_segment_line(struct dm_task *dmt,
 	/* Unlike normal targets, current VDO requires device path */
 	if (dm_snprintf(data_dev, sizeof(data_dev), "/dev/dm-%u", seg->vdo_data->info.minor) < 0) {
 		log_error("Can create VDO data volume path for %s.", data);
-		return_0;
+		return 0;
 	}
 
 	EMIT_PARAMS(pos, "%s %u %s " FMTu64 " " FMTu64 " %u on %s %s "


