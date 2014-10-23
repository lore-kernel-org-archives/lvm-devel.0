From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 23 Oct 2014 08:21:13 +0000 (UTC)
Subject: master - report: lv_permissions: display read-only/read-only-override instead of blank when LV is not writeable
Message-ID: <20141023082113.6288361163@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b611bb816eef3e363e005b48b881e933c3de9e2
Commit:        4b611bb816eef3e363e005b48b881e933c3de9e2
Parent:        2c8e7821c31245e3f7c1d56a67eb7f38d4b37001
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 23 10:18:29 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 23 10:18:29 2014 +0200

report: lv_permissions: display read-only/read-only-override instead of blank when LV is not writeable

Before this patch:
$ lvs -o name,lv_attr,lv_permissions
  LV    Attr       LPerms
  root  -wi-ao---- writeable
  swap  -wi-ao---- writeable
  lvol0 -Ri-a-----
  lvol1 -ri-a-----
  lvol2 -wi-a----- writeable
  lvol3 -ri-------

With this patch applied:
$ lvs -o name,lv_attr,lv_permissions
  LV    Attr       LPerms
  root  -wi-ao---- writeable
  swap  -wi-ao---- writeable
  lvol0 -Ri-a----- read-only-override
  lvol1 -ri-a----- read-only
  lvol2 -wi-a----- writeable
  lvol3 -ri------- read-only

("read-only-override" is displayed if the "writeable" permission
is overriden based on "activation/read_only_volume_list" lvm.conf
setting)
---
 WHATS_NEW           |    1 +
 lib/report/values.h |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0d4487e..2d644c5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Fix lv_permissions reporting to display read-only{-override} instead of blank.
   Fix liblvm2cmd and lvm shell to respect quotes around args in cmd line string.
   Permit extent sizes > 128KB that are not power of 2 with lvm2 format.
   Remove workaround for lvm2-monitor.service hang on stop if lvmetad stopped.
diff --git a/lib/report/values.h b/lib/report/values.h
index 7425bc6..fb368d4 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -77,8 +77,8 @@ FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "", "open")
 FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "", "skip activation", "skip")
 FIELD_RESERVED_BINARY_VALUE(zero, zero, "", "zero")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, "", FIRST_NAME(lv_permissions_rw), "writeable", "rw", "read-write")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", FIRST_NAME(lv_permissions_r), "", "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", FIRST_NAME(lv_permissions_r_override), "", "read-only-override", "ro-override", "r-override", "R")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", FIRST_NAME(lv_permissions_r), "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", FIRST_NAME(lv_permissions_r_override), "read-only-override", "ro-override", "r-override", "R")
 FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, "", RESERVED(number_undef_64), "auto")
 
 /* *INDENT-ON* */


