From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 17 Jan 2008 12:56:26 -0500
Subject: [PATCH] Add verbose log messages for LV stacking
Message-ID: <478F96CA.6020908@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding verbose log message for '-vvvv'.

Examples:

When adding a temporary layer for mirror resync:
...
#metadata/lv_manip.c:1861     Creating logical volume lvol1_mimagetmp_2
#metadata/lv_manip.c:2409       Inserting layer lvol1_mimagetmp_2 for lvol1
#metadata/lv_manip.c:346       Stack lvol1:0[0] on LV lvol1_mimagetmp_2:0
#metadata/lv_manip.c:46       Adding lvol1:0 as an user of lvol1_mimagetmp_2
..
#metadata/lv_manip.c:266       Remove lvol1:0[0] from the top of LV lvol1_mimage
tmp_2:0
#metadata/lv_manip.c:72       lvol1:0 is no longer a user of lvol1_mimagetmp_2
#metadata/lv_manip.c:346       Stack lvol1:0[0] on LV lvol1_mimagetmp_2:0
#metadata/lv_manip.c:46       Adding lvol1:0 as an user of lvol1_mimagetmp_2
#metadata/lv_manip.c:346       Stack lvol1:0[1] on LV lvol1_mimage_2:0
#metadata/lv_manip.c:46       Adding lvol1:0 as an user of lvol1_mimage_2
..

Then, removing the temporary layer:
#metadata/mirror.c:456       Reducing mirror set from 2 to 1 image(s) and no log volume.
#metadata/lv_manip.c:266       Remove lvol1:0[1] from the top of LV lvol1_mimage_2:0
#metadata/lv_manip.c:72       lvol1:0 is no longer a user of lvol1_mimage_2
#metadata/lv_manip.c:2336       Removing layer lvol1_mimagetmp_2 for lvol1
#metadata/lv_manip.c:346       Stack lvol1:0[2] on LV lvol1_mimage_2:0
#metadata/lv_manip.c:46       Adding lvol1:0 as an user of lvol1_mimage_2
...

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: add-verbose-log-for-add-mirror.patch
Type: text/x-patch
Size: 3298 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080117/f0d541fd/attachment.bin>
