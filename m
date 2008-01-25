From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 25 Jan 2008 15:58:28 -0500
Subject: [PATCH 3/3] Additional test case for t-mirror-basic.sh
Message-ID: <479A4D74.1070307@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add test cases about 'lvchange --resync' to t-mirror-basic.sh.

Without the PATCH 1, the added tests will fail.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: test-mirror-resync.patch
Type: text/x-patch
Size: 1298 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080125/e706b8d6/attachment.bin>
