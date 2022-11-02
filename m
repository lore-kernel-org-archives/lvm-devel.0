From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  2 Nov 2022 13:00:21 +0000 (GMT)
Subject: main - device_mapper: vdo V4 avoid messaging
Message-ID: <20221102130021.954C83856947@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=36a923926c2c27c1a8a5ac262387d2a4d3e620f8
Commit:        36a923926c2c27c1a8a5ac262387d2a4d3e620f8
Parent:        2e79b005c2013fb03d8a48a3cfd8e70a982dd65b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 27 23:58:42 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 2 13:59:34 2022 +0100

device_mapper: vdo V4 avoid messaging

With V4 format build table line with compression and
deduplication and skip sending any messages to set up
these parameters.
---
 device_mapper/libdm-deptree.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 0445e1b4b..02a56c8e3 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2894,12 +2894,15 @@ static int _vdo_emit_segment_line(struct dm_task *dmt,
 			    (seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_ASYNC_UNSAFE) ? "async-unsafe" : "auto", // policy
 			    seg->vdo_name);
 	} else {
-		EMIT_PARAMS(pos, "V4 %s " FMTu64 " %u " FMTu64 " %u ",
+		EMIT_PARAMS(pos, "V4 %s " FMTu64 " %u " FMTu64 " %u "
+			    "deduplication %s compression %s ",
 			    data_dev,
 			    seg->vdo_data_size / 8, // this parameter is in 4K units
 			    seg->vdo_params.minimum_io_size * UINT32_C(512), //  sector to byte units
 			    seg->vdo_params.block_map_cache_size_mb * UINT64_C(256),	// 1MiB -> 4KiB units
-			    seg->vdo_params.block_map_era_length);
+			    seg->vdo_params.block_map_era_length,
+			    seg->vdo_params.use_deduplication ? "on" : "off",
+			    seg->vdo_params.use_compression ? "on" : "off");
 	}
 
 	EMIT_PARAMS(pos, "maxDiscard %u ack %u bio %u bioRotationInterval %u cpu %u hash %u logical %u physical %u",
@@ -4376,7 +4379,8 @@ int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 	seg->vdo_name = vdo_pool_name;
 	seg->vdo_data_size = data_size;
 
-	node->props.send_messages = 2;
+	if (seg->vdo_version < 4)
+		node->props.send_messages = 2;
 
 	return 1;
 }

