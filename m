From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  8 Oct 2015 11:45:11 +0000 (UTC)
Subject: master - report: identify LV hodling sanlock locks as 'private, lockd, sanlock' within lv_role report field
Message-ID: <20151008114511.90E1260E2D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e04424e87e66df22578d1e4d2488615cd3692873
Commit:        e04424e87e66df22578d1e4d2488615cd3692873
Parent:        277dd0aa7a9013697ae99164900d8d8ec12a2850
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 8 13:44:21 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 8 13:44:29 2015 +0200

report: identify LV hodling sanlock locks as 'private,lockd,sanlock' within lv_role report field

Before this patch:
$ lvs -a -o name,layout,role test/lvmlock
  LV        Layout     Role
  [lvmlock] linear     public

With this patch applied:
$ lvs -a -o name,layout,role test/lvmlock
  LV        Layout     Role
  [lvmlock] linear     private,lockd,sanlock
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5da1552..227530d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Properly identify internal LV holding sanlock locks within lv_role field.
   Add metadata_devices and seg_metadata_le_ranges report fields for raid vols.
   Fix lvm2-{activation,clvmd,cmirrord,monitor} service to exec before mounting.
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 48d7d34..3e870d5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -129,6 +129,8 @@ enum {
 	LV_TYPE_RAID6_ZR,
 	LV_TYPE_RAID6_NR,
 	LV_TYPE_RAID6_NC,
+	LV_TYPE_LOCKD,
+	LV_TYPE_SANLOCK
 };
 
 static const char *_lv_type_names[] = {
@@ -173,6 +175,8 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_RAID6_ZR] =				SEG_TYPE_NAME_RAID6_ZR,
 	[LV_TYPE_RAID6_NR] =				SEG_TYPE_NAME_RAID6_NR,
 	[LV_TYPE_RAID6_NC] =				SEG_TYPE_NAME_RAID6_NC,
+	[LV_TYPE_LOCKD] =				"lockd",
+	[LV_TYPE_SANLOCK] =				"sanlock",
 };
 
 static int _lv_layout_and_role_mirror(struct dm_pool *mem,
@@ -505,6 +509,13 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 	if (!_lv_layout_and_role_thick_origin_snapshot(mem, lv, *layout, *role, &public_lv))
 		goto_bad;
 
+	if (lv_is_lockd_sanlock_lv(lv)) {
+		if (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_LOCKD]) ||
+		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_SANLOCK]))
+			goto_bad;
+		public_lv = 0;
+	}
+
 	/*
 	 * If layout not yet determined, it must be either
 	 * linear or striped or mixture of these two.


