From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 20 Dec 2007 13:02:56 -0500
Subject: [PATCH mirror 3/13] Enable layer specification in remove_layer_from_lv()
In-Reply-To: <476AA7BC.9080708@ce.jp.nec.com>
References: <476AA7BC.9080708@ce.jp.nec.com>
Message-ID: <476AAE50.3030707@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Added layer_lv argument to remove_layer_from_lv().

remove_layer_from_lv() has implicitly removed the top-most layer.
It won't work if the layer can be stacked.
The caller knows which layer it wants to remove.

find_parent_for_layer() will help find a parent LV for specified layer LV.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-add-layer-spec-to-remove_layer_from_lv.patch
Type: text/x-patch
Size: 3914 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071220/371afea4/attachment.bin>
