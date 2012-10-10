From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 10 Oct 2012 19:56:13 +0000 (UTC)
Subject: master - pvscan --cache: Also read metadata from LVM1 PVs (BZ 863401).
Message-ID: <20121010195613.311F4236C@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=deea86c7f49ea825608826e29b56a005e2c9e747
Commit:        deea86c7f49ea825608826e29b56a005e2c9e747
Parent:        2ba9fb4019f737783606d886b96db59570850937
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 10 21:49:40 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 10 21:55:24 2012 +0200

pvscan --cache: Also read metadata from LVM1 PVs (BZ 863401).

---
 lib/cache/lvmetad.c        |    6 ++++++
 test/shell/lvmetad-lvm1.sh |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index b5e3787..18794be 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -823,6 +823,12 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 		goto_bad;
 
 	lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
+
+	/* LVM1 VGs have no MDAs. */
+	if (!baton.vg && lvmcache_fmt(info) == get_format_by_name(cmd, "lvm1"))
+		baton.vg = ((struct metadata_area *) dm_list_first(&baton.fid->metadata_areas_in_use))->
+			ops->vg_read(baton.fid, lvmcache_vgname_from_info(info), NULL, 0);
+
 	if (!baton.vg)
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 
diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index c183fec..528eec2 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -17,5 +17,6 @@ pvcreate --metadatatype 1 $dev1
 vgscan --cache
 pvs | grep $dev1
 vgcreate --metadatatype 1 $vg1 $dev1
+vgscan --cache
 vgs | grep $vg1
 pvs | grep $dev1


