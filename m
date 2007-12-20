From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 20 Dec 2007 13:03:24 -0500
Subject: [PATCH mirror 7/13] lv_extend() to cope with stacked mirror
In-Reply-To: <476AA7BC.9080708@ce.jp.nec.com>
References: <476AA7BC.9080708@ce.jp.nec.com>
Message-ID: <476AAE6C.9000600@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Mirrored LV could be stacked with temporary resync layers.
So lv_extend() should walk down the stack.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-extend.patch
Type: text/x-patch
Size: 2886 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071220/227e5519/attachment.bin>
