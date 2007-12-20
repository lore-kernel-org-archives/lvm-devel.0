From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 20 Dec 2007 13:03:12 -0500
Subject: [PATCH mirror 5/13] lv_mirror_count() to cope with stacked mirror
In-Reply-To: <476AA7BC.9080708@ce.jp.nec.com>
References: <476AA7BC.9080708@ce.jp.nec.com>
Message-ID: <476AAE60.5020800@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Change lv_mirror_count() to cope with stacked mirror with resync layers.

When adding mirrors to already mirrored LV, LVM2 will stack a temporary
mirror layer for resync.

So the lv_mirror_count() should take into account these things:
  - loop down through the mirror stack
  - exclude the resync LV from the count

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-lv_mirror_count.patch
Type: text/x-patch
Size: 2114 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071220/bf5cee0f/attachment.bin>
