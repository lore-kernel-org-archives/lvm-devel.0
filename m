From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 12 Dec 2006 17:55:04 -0500
Subject: [PATCH LVM2] Clean up the iteration through policies
Message-ID: <457F3348.40305@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch will clean up the iteration through allocation
policies.

Current code just duplicates the lines with changing only
the policy parameter, which is hard to read and error prone.

Patch applicable to LVM2 2.02.16.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: cleanup-policy-iteration.patch
Type: text/x-patch
Size: 3016 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20061212/f490ca12/attachment.bin>
