From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 20 Dec 2007 13:03:45 -0500
Subject: [PATCH mirror 9/13] Add collapsing feature for stacked mirror
In-Reply-To: <476AA7BC.9080708@ce.jp.nec.com>
References: <476AA7BC.9080708@ce.jp.nec.com>
Message-ID: <476AAE81.4000803@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is the main patch of this patchset.

Add collapsing feature to the stacked mirror.
dmeventd should be changed to call it when it detects the
completion of resync.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-collapse-layers.patch
Type: text/x-patch
Size: 5654 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071220/2a0a0ecb/attachment.bin>
