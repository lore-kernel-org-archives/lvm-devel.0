From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 14:26:58 +0000 (UTC)
Subject: master - report: use info
Message-ID: <20150120142658.40CD4612D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a625812bec4597adb6e71816130dacac2ff38b34
Commit:        a625812bec4597adb6e71816130dacac2ff38b34
Parent:        3b78d5237ddc7dc8d328bd1b16628c5a61454826
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 20 15:25:05 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 15:25:05 2015 +0100

report: use info

Use LVSINFO since  LVSSTATUS only fills status
---
 lib/report/columns.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index fbbbe9d..2b788c1 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -38,7 +38,7 @@ FIELD(LVS, lv, STR, "LV", lvid, 4, lvfullname, lv_full_name, "Full name of LV in
 FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV. Blank for internal LVs.", 0)
 FIELD(LVS, lv, STR, "DMPath", lvid, 6, lvdmpath, lv_dm_path, "Internal device-mapper pathname for LV (in /dev/mapper directory).", 0)
 FIELD(LVS, lv, STR, "Parent", lvid, 6, lvparent, lv_parent, "For LVs that are components of another LV, the parent LV.", 0)
-FIELD(LVSSTATUS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
+FIELD(LVSINFO, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
 FIELD(LVS, lv, STR_LIST, "Layout", lvid, 10, lvlayout, lv_layout, "LV layout.", 0)
 FIELD(LVS, lv, STR_LIST, "Role", lvid, 10, lvrole, lv_role, "LV role.", 0)
 FIELD(LVS, lv, BIN, "InitImgSync", lvid, 10, lvinitialimagesync, lv_initial_image_sync, "Set if mirror/RAID images underwent initial resynchronization.", 0)


