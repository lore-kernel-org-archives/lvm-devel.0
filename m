From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 04 Jan 2008 10:12:03 -0500
Subject: [PATCH lvconvert 1/11] Correct 'const' for _lv_mimage_in_sync()
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <477E4CC3.2050004@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The patch removes this warning:

report/report.c:315: warning: passing argument 1 of '_lv_mimage_in_sync' discards qualifiers from pointer target type

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-const-correctness-for-lv_mimage_in_sync.patch
Type: text/x-patch
Size: 597 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080104/4e2c5353/attachment.bin>
