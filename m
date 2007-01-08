From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 08 Jan 2007 12:11:53 -0500
Subject: [LVM2 PATCH] (4/5) Remove unnecessary prev_lvseg checks
In-Reply-To: <45A2751E.5010707@ce.jp.nec.com>
References: <45A2751E.5010707@ce.jp.nec.com>
Message-ID: <45A27B59.50600@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In _find_parallel_space(), contiguous and cling are set
only when prev_lvseg != NULL.
So there is no need to check it again.


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 04-remove-unnecessary-prev_lvseg-checks.patch
Type: text/x-patch
Size: 1375 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070108/63bfec6e/attachment.bin>
