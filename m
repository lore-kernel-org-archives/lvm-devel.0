From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 18 Apr 2007 15:23:27 -0400
Subject: [PATCH] LVM2: (1/2) Use dm_regex
In-Reply-To: <46264BA6.3050104@ce.jp.nec.com>
References: <46264A57.1020800@ce.jp.nec.com> <46264BA6.3050104@ce.jp.nec.com>
Message-ID: <4626702F.9000307@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch removes lib/regex from LVM2 and uses dm_regex, instead.

Corresponding patch for libdevmapper is this:
[PATCH] libdevmapper: (3/6) Move lib/regex from LVM2
https://www.redhat.com/archives/dm-devel/2007-April/msg00028.html

No change in functionality.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-remove-use-dm_regex.patch
Type: text/x-patch
Size: 23254 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070418/dd0e3a38/attachment.bin>
