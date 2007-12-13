From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:03:40 -0500
Subject: [PATCH pvmove 4/9] Change pvmove to use the generalized APIs
In-Reply-To: <476198D3.1080003@ce.jp.nec.com>
References: <476198D3.1080003@ce.jp.nec.com>
Message-ID: <47619E2C.7020202@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch changes pvmove to use the generic APIs added in
the previous patches for "pvmove" layer insertion and mirror
creation.

Changes since rev2:
  * Use the renamed APIs
      - add_mirrors_to_segments()
      - split_parent_segments_for_layer()

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-pvmove-use-generalized-conversion.patch
Type: text/x-patch
Size: 10360 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/770fbb72/attachment.bin>
