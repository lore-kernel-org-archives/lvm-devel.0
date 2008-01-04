From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 04 Jan 2008 10:12:31 -0500
Subject: [PATCH lvconvert 5/11] Don't insert temporary layer for corelog mirror
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <477E4CDF.8060501@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvconvert inserts a temporary layer so that it can sync newly added
mirrors while keeping the original mirror in-sync.
However, LVM2 manages in-sync status for corelog mirror by
the global _mirror_in_sync variable.
So the insertion just duplicates the sync effort.

If the original mirror is corelog, we can just add mimage LV to it
and restart sync.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-dont-insert-tmplayer-for-corelog-mirror.patch
Type: text/x-patch
Size: 1834 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080104/ebdb32d8/attachment.bin>
