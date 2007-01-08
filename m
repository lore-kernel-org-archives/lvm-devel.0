From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 08 Jan 2007 12:11:37 -0500
Subject: [LVM2 PATCH] (2/5) Fix mirror-log-only allocation failure
In-Reply-To: <45A2751E.5010707@ce.jp.nec.com>
References: <45A2751E.5010707@ce.jp.nec.com>
Message-ID: <45A27B49.6030905@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the log-only allocation failed on the first policy,
it doesn't try the next available policy but just quit the loop and fail
because in that case both "allocated" and "new_extents" are same.
It's not correct. It should try the next policy if it's available.

The function allocating_log() is introduced to separate the logic
to determine if the log allocation is still needed.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: 02-fix-mirror-log-only-allocation-failure.patch
Type: text/x-patch
Size: 1284 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070108/6f7e0360/attachment.bin>
