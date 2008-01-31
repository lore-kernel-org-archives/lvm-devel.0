From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 30 Jan 2008 20:33:07 -0500
Subject: [PATCH] Monitor LVs not at the top-level
Message-ID: <47A12553.3030708@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Monitoring is done only for the top-level LV.
So if PV failure occurs during the mirror conversion,
the failure is not handled by dmeventd.

This patch fixes it by recursing for AREA_LV segments.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: monitor-stacked-lv.patch
Type: text/x-patch
Size: 1399 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080130/5c7448d3/attachment.bin>
