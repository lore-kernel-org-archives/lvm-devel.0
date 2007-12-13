From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:03:51 -0500
Subject: [PATCH pvmove 6/9] Remove unused can_split param from allocate_extents()
In-Reply-To: <476198D3.1080003@ce.jp.nec.com>
References: <476198D3.1080003@ce.jp.nec.com>
Message-ID: <47619E37.7010607@ce.jp.nec.com>
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
Size: 3593 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/ac87e4f1/attachment.bin>
