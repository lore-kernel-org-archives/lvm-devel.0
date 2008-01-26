From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 25 Jan 2008 21:52:04 -0500
Subject: 'Resuming before suspend' problem
In-Reply-To: <479A7B12.3060200@ce.jp.nec.com>
References: <479A7B12.3060200@ce.jp.nec.com>
Message-ID: <479AA054.6050001@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jun'ichi Nomura wrote:
> Attached is a patch to workaround the problem that resuming
> of a inserted layer occurs before the suspending of the
> original mirror.

This is an updated version of the workaround patch.
The activation of layer LV should be only done
when the layer is inserted.
That's what pvmove code currently does.
(lv->status | CONVERTING) could be true if the layer
has already been inserted.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-lvconvert-resume-before-suspend.patch
Type: text/x-patch
Size: 3319 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080125/b81f64e0/attachment.bin>
