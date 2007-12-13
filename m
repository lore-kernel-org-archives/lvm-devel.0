From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:03:34 -0500
Subject: [PATCH pvmove 2/9] Add add_mirrors_to_segments()
In-Reply-To: <476198D3.1080003@ce.jp.nec.com>
References: <476198D3.1080003@ce.jp.nec.com>
Message-ID: <47619E26.50909@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add add_mirrors_to_segments().

The function adds mirrors to each segment in the LV.

Changes since rev2:
  * Use seg_is_{striped,mirrored} for segtype check
  * Changed the API name:
      - convert_segments_mirrored() -> add_mirrors_to_segments()
  * Add error message to add_mirrors_to_segments()
  * Removed pvmove-specific comment from add_mirrors_to_segments()

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-convert-segments-mirrored.patch
Type: text/x-patch
Size: 6013 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/1f38115f/attachment.bin>
