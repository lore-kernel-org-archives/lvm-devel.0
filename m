From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 30 Jan 2008 20:40:21 -0500
Subject: [PATCH] Remove some gcc warning
Message-ID: <47A12705.8070706@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

make.tmpl contains some commented-out CFLAGS.
They are sometimes useful to check the code,
e.g. signed/unsigned corresness, so I'm trying to
uncomment them before posting a patch.

Attached patch removes some of making-sense warnings
that appear when such additional CFLAGS are turned on.
(Most of them are attributing 'unused')

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: cleanup-warnings.patch
Type: text/x-patch
Size: 8078 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080130/b01c2501/attachment.bin>
