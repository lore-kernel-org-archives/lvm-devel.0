From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 04 Jan 2008 10:12:18 -0500
Subject: [PATCH lvconvert 3/11] Multiple fixes about to-corelog conversion
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <477E4CD2.4030704@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

_remove_mirror_images() is the core function used for both
mirror image removal and mirror log removal.
However, it has some bugs and to-corelog conversion didn't work
at all.

The patches fixes them at once.
Please see the patch header for detailed information about
each bug.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-corelog-convert.patch
Type: text/x-patch
Size: 4452 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080104/2f648174/attachment.bin>
