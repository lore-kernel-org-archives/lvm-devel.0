From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 06 Dec 2007 11:51:11 -0500
Subject: [PATCH pvmove 5/6] Remove unused mirrored_pv/mirrored_pe params from internal code
In-Reply-To: <475825EF.6000803@ce.jp.nec.com>
References: <475825EF.6000803@ce.jp.nec.com>
Message-ID: <4758287F.1070507@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Since pvmove now uses generalized APIs, mirrored_pv and mirrored_pe,
special params to pass the source PV segment to allocator, are
no longer used.

The patch removes them from allocation internal codes.
I left lv_extend() untouched since it was not changed by
the previous attempt.
Of course, it's ok to remove them from lv_extend(), too.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-remove-unused-mirror_pe-args.patch
Type: text/x-patch
Size: 4595 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071206/2abae80e/attachment.bin>
