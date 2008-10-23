From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 23 Oct 2008 15:59:52 +0900
Subject: [PATCH] Fix _mimagetmp left activated after upconversion of inactive mirrored LV
Message-ID: <490020E8.4000401@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

> commit e36b529d7381725e839befcf001e9453eda6886a
> Author: Alasdair Kergon <agk@redhat.com>
> Date:   Fri Oct 17 10:57:14 2008 +0000
> 
>     Use temp table to set device size when converting mirrors.
>     
>     (Avoids having same mirror table loaded twice concurrently by first
>     using a 'zero' table to set the size of the device so when mirror
>     table is preloaded it doesn't have to be activated immediately.)

This change broke t-mirror-vgreduce-removemissing.sh test.

>   Running t-mirror-vgreduce-removemissing.sh ...   FAILED!
>   ...
>   1 test_3way_mirror_plus_1_fail_1_() called from ./t-mirror-vgreduce-removemissing.sh:217

The test failed as follows:
  1. Upconvert existing inactive mirror
     (At this point, 'lv_mimagetmp_x' is activated while the
      top-level lv is inactive.)
  2. Fail the PV used by 'lv_mimage_0' for testing
  3. 'vgreduce --removemissing --force vg' will reconfigure
      the mirrored LV correctly.
      However, during the reconfiguration process,
      'lv_mimagetmp_x' is resumed, i.e. activated in this case,
      while the top-level lv is still inactive.
  4. The test succeeds and does 'lvremove -ff vg' for the next test.
      The lvremove successfully removes the lv including 'lv_mimagetmp_x'
      however it doesn't deactivate 'lv_mimagetmp_x'
      because 'lv' is already inactive.
  5. The next test tries to lvcreate mirrored LV and fails
      because there are remaining dm devices such as lv_mlog.

The layer lv with temporary table should be activated only when
the parent lv, from which the segments are moved to the layer lv,
is active.

With this patch applied, 'make check' passed all tests.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-dont-activate-layer-if-parent-is-not-active.patch
Type: application/mbox
Size: 602 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081023/8e441846/attachment.mbox>
