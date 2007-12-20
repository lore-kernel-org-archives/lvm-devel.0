From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 20 Dec 2007 13:03:17 -0500
Subject: [PATCH mirror 6/13] remove_mirror_images() to cope with stacked mirror
In-Reply-To: <476AA7BC.9080708@ce.jp.nec.com>
References: <476AA7BC.9080708@ce.jp.nec.com>
Message-ID: <476AAE65.2020003@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Change remove_mirror_images()
  - take LV as an argument, instead of LV segment, because segment-lv
    relationship could change after the layer removal
  - to cope with the stacked mirror LV, check the difference between
    lv_mirror_count() and seg->area_count.
    Iterate in this way: remove legs from the top-level mirror, if
    the mirror is turned to linear, collapse one layer and restart
    with remainder.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-remove_mirror_images.patch
Type: text/x-patch
Size: 7968 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071220/134f412b/attachment.bin>
