From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 16 Jan 2008 14:48:01 -0500
Subject: [PATCH] Fix error message for mirror log allocation failure
Message-ID: <478E5F71.1090000@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In the course of pvmove/lvconvert restructuring,
an error message for pvmove was copied in to mirror log
allocation code.

Attached is a patch to fix it.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-msg-for-log-allocation-failure.patch
Type: text/x-patch
Size: 1026 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080116/8fda64fe/attachment.bin>
