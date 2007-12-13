From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:04:07 -0500
Subject: [PATCH pvmove Appendix] pvmove test cases for 'make check'
In-Reply-To: <476198D3.1080003@ce.jp.nec.com>
References: <476198D3.1080003@ce.jp.nec.com>
Message-ID: <47619E47.609@ce.jp.nec.com>
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

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-add-pvmove-test.patch
Type: text/x-patch
Size: 13799 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/dd739db4/attachment.bin>
