From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 04 Jan 2008 10:12:37 -0500
Subject: [PATCH lvconvert 6/11] init_mirror_in_sync(0) for corelog mirror addition
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <477E4CE5.8050305@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Since corelog mirror is controlled by the global _mirror_in_sync,
lv_add_mirrors() should explicitly reset it when adding mirrors
with corelog.
Otherwise, it might be set 'in-sync' in some other places and
skip sync process.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-init-sync-status-for-corelog.patch
Type: text/x-patch
Size: 844 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080104/c58e3f54/attachment.bin>
