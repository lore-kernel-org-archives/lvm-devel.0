From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 21 Dec 2007 20:23:05 -0500
Subject: [PATCH 2/4] lvconvert to refuse mirror addition to 'nosync' LV
Message-ID: <476C66F9.7020304@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

LVM2 will not do initial syncing of mirrors if the LV
is created with '--nosync' option.
(Such LV is shown as 'M' in the first character of Attr field.)
Writes after the LV creation will go to all mirrors.

The option might be useful if admin wants to avoid syncing I/O
at the time.

However, if lvconvert adds a new mirror to such LV,
we can't skip syncing. Otherwise, mirrors are kept out-of-sync
and makes no sense.

This patch changes lvconvert to check the LV status and
refuse mirror addition if the LV is 'nosync'.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-refuse-add-mirror-to-nosync-lv.patch
Type: text/x-patch
Size: 1849 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071221/b5d88ebc/attachment.bin>
