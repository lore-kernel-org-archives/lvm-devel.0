From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 25 Jan 2008 16:29:38 -0500
Subject: [PATCH] Show LE range instead of just a starting LE
Message-ID: <479A54C2.2000308@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Attached patch changes the validator error message
to show LE range instead of just a starting LE.

>   LV lv_mlog is used by LV lv:0, but missing ptr from lv to lv_mlog
>   Internal error: LV segments corrupted in lv_mlog.
>   Failed to write intermediate VG metadata.

The '0' in the above 'lv:0' means the starting LE.
The patch changes it to show the range of the LE instead.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: improve-validator-error-message-for-stacking.patch
Type: text/x-patch
Size: 1010 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080125/4eb061a1/attachment.bin>
