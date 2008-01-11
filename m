From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:49:46 -0500
Subject: [PATCH 11/11] Fix _remove_mirror_images() to skip AREA_LV
In-Reply-To: <4787FA27.8050300@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com>
Message-ID: <4788009A.1070405@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not remove mirror image on AREA_LV.

If the mirror image LV consists of AREA_LV, current version
of remove_mirror_images() always remove it ignoring removable_pvs
constraint.
That's not correct.

The FIXME comment suggests recursing down the AREA_LV.
However, it might not be sufficient if we can have LVs with
different structure.

Currently, we won't hit this check.
So just leave it for safety side.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-remove_mirror_images-dont-remove-stacked-mirror.patch
Type: text/x-patch
Size: 1048 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/4e8342fa/attachment.bin>
