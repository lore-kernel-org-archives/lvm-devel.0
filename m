From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue, 16 Aug 2016 11:40:08 +0000 (UTC)
Subject: master - lvcreate: better error message creating RAID LV on < 4 KiB VG extent size
Message-ID: <20160816114008.71EE36056F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=73df2aedf9788dcf2dbf09f20f8783c6d2108e75
Commit:        73df2aedf9788dcf2dbf09f20f8783c6d2108e75
Parent:        114db6f745a229e1c3bf2dc95cc45c020cbcfca8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Aug 16 13:39:40 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Aug 16 13:39:40 2016 +0200

lvcreate: better error message creating RAID LV on < 4 KiB VG extent size

Creating a RaidLV in VGs with very small extent sizes caused
late failure in the kernel giving a not very informative error
message. Catch the attempt early and display failure message
'Unable to create RAID LV: requires minimum VG extent size 4.00 KiB'.

- resoves rhbz1179970
---
 tools/lvcreate.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index ccd07f0..a389d79 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1255,10 +1255,17 @@ static int _check_raid_parameters(struct volume_group *vg,
 				  struct lvcreate_cmdline_params *lcp)
 {
 	unsigned devs = lcp->pv_count ? : dm_list_size(&vg->pvs);
+	uint64_t page_sectors = lvm_getpagesize() >> SECTOR_SHIFT;
 	struct cmd_context *cmd = vg->cmd;
 	int old_stripes = !arg_is_set(cmd, stripes_ARG) &&
 			  find_config_tree_bool(cmd, allocation_raid_stripe_all_devices_CFG, NULL);
 
+	if (vg->extent_size < page_sectors) {
+		log_error("Unable to create RAID LV: requires minimum VG extent size %s",
+			  display_size(vg->cmd, page_sectors));
+		return 0;
+	}
+
 	/*
 	 * If we requested the previous behaviour by setting
 	 * "allocation/raid_stripe_all_devices = 1" and the


