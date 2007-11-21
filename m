From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 16:28:53 -0500
Subject: [PATCH pvmove 3/3] use generic mirror allocation for pvmove
In-Reply-To: <4744A21E.7090601@ce.jp.nec.com>
References: <4744A21E.7090601@ce.jp.nec.com>
Message-ID: <4744A315.4000909@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Extent allocation code used to have special support for pvmove
since pvmove already knows PV area to use for mirrored segment.

This patch changes the pvmove's logic to the way similar to
what lvconvert does for mirrored LV.
Not only clean up the allocation code, it also allows
splitted allocation for destination areas.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-pvmove-generalized-mirror-allocation.patch
Type: text/x-patch
Size: 14681 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/34e24058/attachment.bin>
