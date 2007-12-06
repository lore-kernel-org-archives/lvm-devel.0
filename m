From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 06 Dec 2007 11:53:16 -0500
Subject: [PATCH pvmove 0/6] Refactoring pvmove with generic APIs
In-Reply-To: <475825EF.6000803@ce.jp.nec.com>
References: <475825EF.6000803@ce.jp.nec.com>
Message-ID: <475828FC.8040307@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Attached is a test script for basic pvmove operations.
More tests are added since the previous version.
I hope it gets included in the test directory for future
regression testings.

To run this, put it in LVM2/test directory, then
  # cd test; ./t-pvmove-basic.sh
With the posted patch set, all tests succeeds.
Without the patches, tests for splitted destinations will fail.

# ./t-pvmove-basic.sh 
*   ok 1: set up temp file and loopback device
*   ok 2: create pv1
*   ok 3: create pv2
*   ok 4: create pv3
*   ok 5: create pv4
*   ok 6: create pv5
*   ok 7: Run this: pvcreate  
*   ok 8: set up a VG
*   ok 9: check environment setup/cleanup
*   ok 10: only specified LV is moved: from pv2 to pv5 only for lv1
*   ok 11: the 1st seg of 3-segs LV is moved: from pv1 of lv1 to pv4
*   ok 12: the 2nd seg of 3-segs LV is moved: from pv2 of lv1 to pv4
*   ok 13: the 3rd seg of 3-segs LV is moved: from pv3 of lv1 to pv4
*   ok 14: 1 out of 3 LVs is moved: from pv4 to pv5
*   ok 15: 2 out of 3 LVs are moved: from pv3 to pv5
*   ok 16: 3 out of 3 LVs are moved: from pv2 to pv5
*   ok 17: move the 1st stripe: from pv2 of lv2 to pv1
*   ok 18: move the 2nd stripe: from pv3 of lv2 to pv1
*   ok 19: move the 3rd stripe: from pv4 of lv2 to pv1
*   ok 20: match to the start of segment:from pv2:0-0 to pv5
*   ok 21: match to the middle of segment: from pv2:1-1 to pv5
*   ok 22: match to the end of segment: from pv2:2-2 to pv5
*   ok 23: no destination split: from pv2:0-2 to pv5
*   ok 24: destination split into 2: from pv2:0-2 to pv5:5-5 and pv4:5-6
*   ok 25: destination split into 3: from pv2:0-2 to {pv3,4,5}:5-5
*   ok 26: alloc normal on same PV for source and destination: from pv3:0-2 to pv3:5-7
*   ok 27: (cleanup previous test)
*   ok 28: alloc anywhere on same PV for source and destination: from pv3:0-2 to pv3:5-7
*   ok 29: alloc anywhere but better area available: from pv3:0-2 to pv3:5-7 or pv5:5-6,pv4:5-5
*   ok 30: alloc contiguous but area not available: from pv2:0-2 to pv5:5-5 and pv4:5-6
*   ok 31: (cleanup previous test)
*   ok 32: alloc contiguous and contiguous area available: from pv2:0-2 to pv5:0-0,pv5:3-5 and pv4:5-6
*   ok 33: multiple source LVs: from pv3 to pv5
*   ok 34: move inactive LV: from pv2 to pv5
*   ok 35: no PEs to move: from pv3 to pv1
*   ok 36: (cleanup previous test)
*   ok 37: no space available: from pv2:0-0 to pv1:0-0
*   ok 38: (cleanup previous test)
*   ok 39: same source and destination: from pv1 to pv1
*   ok 40: (cleanup previous test)
*   ok 41: pvmove abort
* passed all 41 test(s)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: t-pvmove-basic.sh
Type: application/x-shellscript
Size: 12446 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071206/c22128ad/attachment.bin>
