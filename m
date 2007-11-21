From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 17:45:47 -0500
Subject: [PATCH pvmove appendix] 'make check' script for testing basic pvmove operations
In-Reply-To: <4744A21E.7090601@ce.jp.nec.com>
References: <4744A21E.7090601@ce.jp.nec.com>
Message-ID: <4744B51B.7050108@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Attached is a test script for basic pvmove operations.
(Not actually in a patch form.)
I hope it gets included in the test directory for future
regression testings.

To run this, put it in LVM2/test directory, then
  # cd test; ./t-pvmove-basic.sh
With the posted patch set, all tests succeeds.
Without the patches, test 15 will fail.

# ./t-pvmove-basic.sh 
*   ok 1: set up temp file and loopback device
*   ok 2: create pv1
*   ok 3: create pv2
*   ok 4: create pv3
*   ok 5: Run this: pvcreate
  /LVM2.work/test/lvm-pvmove-basic.xqtoq24243/root/dev/mapper/pv1 
  /LVM2.work/test/lvm-pvmove-basic.xqtoq24243/root/dev/mapper/pv2
  /LVM2.work/test/lvm-pvmove-basic.xqtoq24243/root/dev/mapper/pv3
*   ok 6: set up a VG
*   ok 7: create a linear LV lv1 on pv1
*   ok 8: create a striped LV lv2 on pv2 and pv3
*   ok 9: pvmove from pv1 to pv1 (same source and destination)
*   ok 10: pvmove failure should not affect lv contents
*   ok 11: pvmove from pv1 to pv2
*   ok 12: pvmove from pv2 to pv1 only for lv1
*   ok 13: pvmove from pv3 (a part of striped LV) to pv1
*   ok 14: pvmove from pv3 to pv1 (no PEs to move)
*   ok 15: pvmove from pv1:0-1 to pv2:2-2 and pv3:3-3 (splitted)
*   ok 16: pvmove abort
*   ok 17: pvmove LV isn't left
* passed all 17 test(s)

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: t-pvmove-basic.sh
Type: application/x-sh
Size: 3588 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/84957a11/attachment.sh>
