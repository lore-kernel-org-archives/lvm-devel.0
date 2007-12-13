From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:03:57 -0500
Subject: [PATCH pvmove 7/9] Add remove_mirrors_from_segments() and remove_layer_from_segments()
In-Reply-To: <476198D3.1080003@ce.jp.nec.com>
References: <476198D3.1080003@ce.jp.nec.com>
Message-ID: <47619E3D.3090409@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add generic interfaces for removing mirrors from segment-by-segment
mirror and removing layers for segments.
(Generalizing pvmove layer removal)

  - remove_layers_for_segments()
      Remove layer below the segments of the LV.
  - remove_layers_for_segments_all()
      Remove the layer from all LVs in the VG.
  - remove_mirrors_from_segments()

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-remove-layer-from-segments.patch
Type: text/x-patch
Size: 6961 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/058defb8/attachment.bin>
