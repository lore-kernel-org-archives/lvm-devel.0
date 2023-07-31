From: Peter Rajnoha (@prajnoha) <gitlab@mg.gitlab.com>
Date: Mon, 31 Jul 2023 11:46:49 +0000
Subject: [Git][lvmteam/lvm2][main] report: fix pv_major and pv_minor report field type
Message-ID: <64c79f2964625_28f85afc311bc@gitlab-sidekiq-low-urgency-cpu-bound-v2-6b77f8c7d6-drrsp.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Peter Rajnoha pushed to branch main at LVM team / lvm2


Commits:
0e9fe272 by Peter Rajnoha at 2023-07-31T13:44:09+02:00
report: fix pv_major and pv_minor report field type

We incorrectly marked pv_major and pv_minor fields as being of string
type, even though the values were already correctly handled as integers
internally. This confused -S|--select that tried to compare string
values instead of integers.

Reported here: https://github.com/lvmteam/lvm2/issues/122

- - - - -


2 changed files:

- WHATS_NEW
- lib/report/columns.h


Changes:

=====================================
WHATS_NEW
=====================================
@@ -1,5 +1,6 @@
 version 2.03.22 - 
 =================================
+  Fix pv_major/pv_minor report field types so they are integers, not strings.
   Always use cachepool name for metadata backup LV for lvconvert --repair.
   Make metadata backup LVs read-only after pool's lvconvert --repair.
   Improve VDO and Thin support with lvmlockd.


=====================================
lib/report/columns.h
=====================================
@@ -179,8 +179,8 @@ FIELD(LABEL, label, STR, "Fmt", type, 0, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
 FIELD(LABEL, label, SIZ, "DevSize", dev, 0, devsize, dev_size, "Size of underlying device in current units.", 0)
 FIELD(LABEL, label, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
-FIELD(LABEL, label, STR, "Maj", dev, 0, devmajor, pv_major, "Device major number.", 0)
-FIELD(LABEL, label, STR, "Min", dev, 0, devminor, pv_minor, "Device minor number.", 0)
+FIELD(LABEL, label, SNUM, "Maj", dev, 0, devmajor, pv_major, "Device major number.", 0)
+FIELD(LABEL, label, SNUM, "Min", dev, 0, devminor, pv_minor, "Device minor number.", 0)
 FIELD(LABEL, label, SIZ, "PMdaFree", type, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
 FIELD(LABEL, label, SIZ, "PMdaSize", type, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
 FIELD(LABEL, label, NUM, "PExtVsn", type, 0, pvextvsn, pv_ext_vsn, "PV header extension version.", 0)



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/0e9fe272bcf508cc2e0c99d986a5c95abb2b93d0

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/0e9fe272bcf508cc2e0c99d986a5c95abb2b93d0
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230731/ea9a0109/attachment.htm>
