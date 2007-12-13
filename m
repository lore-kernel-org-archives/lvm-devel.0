From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:31:22 -0500
Subject: [PATCH lvconvert 1/6] Add insert_layer_for_lv() / remove_layer_from_lv()
In-Reply-To: <47619E84.2060905@ce.jp.nec.com>
References: <47619E84.2060905@ce.jp.nec.com>
Message-ID: <4761A4AA.2060006@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add insert_layer_for_lv() / remove_layer_from_lv().

insert_layer_for_lv() simply creates an layer LV with specified suffix,
move all segments of the LV to the layer LV ,then maps linearly
from the LV to the layer LV.

remove_layer_from_lv() removes the top-level layer from the LV.
This might be too simple.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-insert-layer-lv.patch
Type: text/x-patch
Size: 4851 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/2acab1c1/attachment.bin>
