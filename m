From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 20 Dec 2007 13:03:03 -0500
Subject: [PATCH mirror 4/13] lv_rename() to walk down the stacked LV
In-Reply-To: <476AA7BC.9080708@ce.jp.nec.com>
References: <476AA7BC.9080708@ce.jp.nec.com>
Message-ID: <476AAE57.2020908@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

_for_each_sub_lv() is used by lv_rename() to rename the
underlying LVs. But it currently handles only 1 layer.
Let it work recursively for more stacked LV.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-lv-rename.patch
Type: text/x-patch
Size: 802 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071220/ae173ca6/attachment.bin>
