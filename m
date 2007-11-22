From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 21:10:01 -0500
Subject: [PATCH mirror 13/13] Allow resizing of mirrored LV with temporary layer
In-Reply-To: <4744DF34.7090701@ce.jp.nec.com>
References: <4744DF34.7090701@ce.jp.nec.com>
Message-ID: <4744E4F9.4010904@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch changes 2 things related to resizing mirror.
  1) Use lv_mirror_count() to calculate the number of existing mirrors
  2) lv_extend() will walk down recursively mirrored LV
     to add allocated extents for each mirror image.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-extend.patch
Type: text/x-patch
Size: 2828 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/2f681e1f/attachment.bin>
