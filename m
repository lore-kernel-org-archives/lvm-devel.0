From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 11 Oct 2007 18:55:24 -0400
Subject: [RFC LVM2] (2/6) Add pv_dev_name() to access PV device name
In-Reply-To: <470EA422.6000003@ce.jp.nec.com>
References: <470EA422.6000003@ce.jp.nec.com>
Message-ID: <470EA9DC.6040700@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In the patch "(6/6) Allow allocation from LV",
PV may be attached to LV.
In that case, the LV's name should be used as the PV's device name.

This patch adds pv_dev_name(), which decides whether dev_name(pv->dev)
or LV name should be used, and convert others to use it.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-pv_dev_name.patch
Type: text/x-patch
Size: 25823 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071011/f7a3c43d/attachment.bin>
