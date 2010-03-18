From: Mikulas Patocka <mpatocka@redhat.com>
Date: Thu, 18 Mar 2010 19:53:37 -0400 (EDT)
Subject: [PAYCH] Don't allow resizing of internal logical volumes
Message-ID: <Pine.LNX.4.64.1003181950140.29893@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

This patch prevents resizing of internal volumes.

BTW.: do you think that *-shared should be treated as a reseved logical 
volume name?
It is really the internal volume name, but the potential problem with it 
is that there may be some systems with existing names *-shared, and 
reserving the name breaks those systems.

Mikulas

---

Don't allow resizing of internal logical volumes.

This patch prevents lvresize from being able to resize internal LVs: mirror
legs (*_mimage_*), mirror log (*_mlog), snapshot placeholder LVs (snapshot*)
and others. Resizing these would leads to unexpected metadata and sometimes
crashes (in case of growing snapshot*).

Note that test for VISIBLE_LV is not sufficient because snapshot0 volumes
have the VISIBLE_LV flag set. So we test the name instead of the flags.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 tools/lvresize.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: LVM2/tools/lvresize.c
===================================================================
--- LVM2.orig/tools/lvresize.c	2010-03-19 00:25:31.000000000 +0100
+++ LVM2/tools/lvresize.c	2010-03-19 00:44:52.000000000 +0100
@@ -323,6 +323,11 @@ static int _lvresize(struct cmd_context 
 
 	lv = lvl->lv;
 
+	if (is_reserved_lvname(lv->name)) {
+		log_error("Can't resize internal logical volume %s", lv->name);
+		return ECMD_FAILED;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't resize locked LV %s", lv->name);
 		return ECMD_FAILED;


