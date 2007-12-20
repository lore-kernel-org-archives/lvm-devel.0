From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 20 Dec 2007 13:02:32 -0500
Subject: [PATCH mirror 1/13] Add 'const' for mirror-related functions
In-Reply-To: <476AA7BC.9080708@ce.jp.nec.com>
References: <476AA7BC.9080708@ce.jp.nec.com>
Message-ID: <476AAE38.2050903@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Some mirror-related functions should use 'const'.
It will save warnings when we use lv_mirror_count() from reporting
function.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: const-mirror.patch
Type: text/x-patch
Size: 3316 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071220/e5c1e5df/attachment.bin>
