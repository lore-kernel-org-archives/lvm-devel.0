From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 14 Mar 2016 09:31:36 +0000 (UTC)
Subject: master - report: Use default vg_name field width too.
Message-ID: <20160314093136.2CC28603F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a39563c0b08a281f170f7e70ec571aa6ef2d9147
Commit:        a39563c0b08a281f170f7e70ec571aa6ef2d9147
Parent:        a78e6960704a42ceadcda89b624137cb7bb7c72e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Mar 14 09:30:51 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Mar 14 09:30:51 2016 +0000

report: Use default  vg_name field width too.

---
 lib/report/columns.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 1abc4c8..4439047 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -149,7 +149,7 @@ FIELD(PVS, pv, BIN, "PInUse", id, 0, pvinuse, pv_in_use, "Set if PV is used.", 0
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 0, vgfmt, vg_fmt, "Type of metadata.", 0)
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
-FIELD(VGS, vg, STR, "VG", name, 4, string, vg_name, "Name.", 0)
+FIELD(VGS, vg, STR, "VG", name, 0, string, vg_name, "Name.", 0)
 FIELD(VGS, vg, STR, "Attr", cmd, 5, vgstatus, vg_attr, "Various attributes - see man page.", 0)
 FIELD(VGS, vg, STR, "VPerms", cmd, 10, vgpermissions, vg_permissions, "VG permissions.", 0)
 FIELD(VGS, vg, BIN, "Extendable", cmd, 0, vgextendable, vg_extendable, "Set if VG is extendable.", 0)


