From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 06 Dec 2007 11:48:21 -0500
Subject: [PATCH pvmove 1/6] Add insert_layer_for_segments_on_pv()
In-Reply-To: <475825EF.6000803@ce.jp.nec.com>
References: <475825EF.6000803@ce.jp.nec.com>
Message-ID: <475827D5.3080808@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add insert_layer_for_segments_on_pv().

The function can be used to insert a layer below the LV,
only for the segments on a specified PV.

Part of the code is derived from pvmove.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-insert-layer-for-segments.patch
Type: text/x-patch
Size: 6599 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071206/77d8cdb6/attachment.bin>
