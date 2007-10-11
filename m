From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 11 Oct 2007 18:56:07 -0400
Subject: [RFC LVM2] (3/6) Add _pv_allocate() (split from _pv_create)
In-Reply-To: <470EA422.6000003@ce.jp.nec.com>
References: <470EA422.6000003@ce.jp.nec.com>
Message-ID: <470EAA07.5050103@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In the patch "(6/6) Allow allocation from LV",
'struct physical_volume' will be allocated from function
other than _pv_create().

This patch splits the allocation/initialization part from
_pv_create().

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-separate-pv_alloc.patch
Type: text/x-patch
Size: 2078 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071011/0afbb97b/attachment.bin>
