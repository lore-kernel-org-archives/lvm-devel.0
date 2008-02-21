From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 21 Feb 2008 12:04:04 -0500
Subject: [PATCH 1/2] Turn off MIRROR_IMAGE flag
Message-ID: <47BDAF04.8040109@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is a prepartion for the next patch.

In _remove_mirror_images(), if the LV becomes a linear,
the mirror layer is removed.
Since the layer LV is no longer a mirror image,
flags set for mirror image should be turned off.

The next patch will add a call to lv_empty() in
remove_layer_from_lv().
Since lv_empty() works recursively for mirror images,
it is necessary to turn off MIRROR_IMAGE before
remove_layer_from_lv() where we don't want lv_empty()
to work recursively.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: release-temporary-mirror-image-before-layer-removal.patch
Type: text/x-patch
Size: 783 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080221/d58dfaef/attachment.bin>
