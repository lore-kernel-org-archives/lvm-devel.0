From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 11 Oct 2007 18:56:37 -0400
Subject: [RFC LVM2] (4/6) Add 'pvseg' to AREA_LV lv_segment_area
In-Reply-To: <470EA422.6000003@ce.jp.nec.com>
References: <470EA422.6000003@ce.jp.nec.com>
Message-ID: <470EAA25.4060404@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently, struct lv_segment_area has a union member and
switches by its type (AREA_PV or AREA_LV).

As a preparation for the patch "(6/6) Allow allocation from LV",
where AREA_LV segment may have pv_segment, this patch changes
struct lv_segment_area.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-use-pvseg-for-AREA_LV.patch
Type: text/x-patch
Size: 1821 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071011/851c7091/attachment.bin>
