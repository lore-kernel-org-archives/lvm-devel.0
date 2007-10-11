From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 11 Oct 2007 18:57:27 -0400
Subject: [RFC LVM2] (5/6) Allow merging AREA_LV striped segments
In-Reply-To: <470EA422.6000003@ce.jp.nec.com>
References: <470EA422.6000003@ce.jp.nec.com>
Message-ID: <470EAA57.2010901@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently, 'striped' segment can only be merged if the segment
is allocated from PV (AREA_PV).

This patch extends the mergeable check to cope with AREA_LV case.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-merge-striped-lv-seg.patch
Type: text/x-patch
Size: 1182 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071011/9f6082ce/attachment.bin>
