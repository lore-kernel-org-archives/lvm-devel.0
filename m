From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Fri, 11 Sep 2020 17:43:20 +0800
Subject: [PATCH 4/4] fix core dump when thinpool size more than the remaining, space of vg
In-Reply-To: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
References: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
Message-ID: <9b305956-c9f9-59c0-78d3-f01c0b302302@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Create thinpool through the lvcreate command,
specify the data device size of the thinpool as x,
the metadata device size as y, and the remaining space of the volume group as z.
When x + y < z and x + 2y > z, then it must enter the core dump.

Example:
"
    sdc                            8:32   0   40G  0 disk
    # pvcreate /dev/sdc
      Physical volume "/dev/sdc" successfully created.
    # vgcreate vg /dev/sdc
      Volume group "vg" successfully created
    # lvcreate  -L 30G --poolmetadatasize 5G -T vg/thinpool
      Thin pool volume with chunk size 64.00 KiB can address at most 15.81 TiB of data.
    lvcreate: metadata/pv_map.c:198: consume_pv_area: Assertion `to_go <= pva->count' failed.
    Aborted (core dumped)
"

When the volume group allocates space, it will surround the assertion
when it finds that its own space is insufficient, leading to coredump.

So before actually creating the thinpool, we will check
if the remaining space of the volume group is sufficient

Signed-off-by: Wu Guanghao<wuguanghao3@huawei.com>
Signed-off-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 tools/lvcreate.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e384291ae..5e86ecba6 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1721,6 +1721,13 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 		if (!handle_pool_metadata_spare(vg, lp->pool_metadata_extents,
 						lp->pvh, lp->pool_metadata_spare))
 			goto_out;
+		
+		if (vg->free_count < (uint64_t)lp->extents + lp->pool_metadata_extents) {
+			log_error("%s doesn't have enough space, create thinpool failed. %s",
+				vg->name, lp->pool_metadata_spare ?
+				"metadata back device occupies part of the VG space" : "");
+			goto_out;
+		}

 		log_verbose("Making pool %s in VG %s using segtype %s",
 			    lp->pool_name ? : "with generated name", lp->vg_name, lp->segtype->name);
-- 


