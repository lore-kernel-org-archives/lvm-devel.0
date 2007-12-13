From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:31:35 -0500
Subject: [PATCH lvconvert 4/6] Change lvcreate to use the new mirror APIs
In-Reply-To: <47619E84.2060905@ce.jp.nec.com>
References: <47619E84.2060905@ce.jp.nec.com>
Message-ID: <4761A4B7.902@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Change lvconvert to use add_mirror_images().

The patch simplifies the lvcreate code and we no longer need
to export allocate_extents() directly to tools.

However, this patch slightly changes the allocation logic.
Original code allocated all mirrors at once.
OTOH, this code creates a linear LV first then adds mirrors to it.
It's better to allocate all at once because otherwise the allocation
code may make worse choice at the first attempt.
To do that, we have to be able to create an empty mirror layers.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvcreate-use-new-mirror-api.patch
Type: text/x-patch
Size: 3257 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/174fcfbb/attachment.bin>
