From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 06 Dec 2007 11:51:49 -0500
Subject: [PATCH pvmove 6/6] Remove unused can_split param from allocate_extents()
In-Reply-To: <475825EF.6000803@ce.jp.nec.com>
References: <475825EF.6000803@ce.jp.nec.com>
Message-ID: <475828A5.3070400@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'can_split' was a parameter to specify that the allocation should
not be splitted even if the policy is not ALLOC_CONTIGUOUS.
It was there for pvmove, which was not able to handle splitted
allocation.

However, since pvmove now can handle splitted destinations,
we can remove the param from allocate_extents().

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-remove-unused-can_split-args.patch
Type: text/x-patch
Size: 3628 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071206/17554318/attachment.bin>
