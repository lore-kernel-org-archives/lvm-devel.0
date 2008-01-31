From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 30 Jan 2008 20:32:40 -0500
Subject: [PATCH 1/2] Fix mirror log name when re-added to converting LV
Message-ID: <47A12538.7030605@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If mirror log is once removed from the mirror LV under conversion
and then re-added during the conversion,
the mirror log name becomes "lv_mimagetmp_x_mlog".
When the conversion completes, the log name is still so
and breaks the convention.

Fix the name generator function to cope with this situation.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-disklog-name.patch
Type: text/x-patch
Size: 2026 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080130/428404bb/attachment.bin>
