From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 21 Feb 2008 12:04:19 -0500
Subject: [PATCH 2/2] Fix lv-seg relationship on layer removal
Message-ID: <47BDAF13.4040503@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When a layer is removed, a linear-mapping segment of its parent
is discarded and segments of the layer are moved to the parent LV.

To discard the linear-mapping layer properly,
we need to call lv_empty() for the parent to release the layer.
Otherwise, the layer LV still has the discarded linear segment
in its segs_using_this_lv list.
(Though it might not have any visible effect because the layer
 is eventually removed.)

Thanks Milan Broz for finding this bug.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: empty-parent-before-layer-removal.patch
Type: text/x-patch
Size: 912 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080221/146aa820/attachment.bin>
