From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 20 Dec 2007 13:03:29 -0500
Subject: [PATCH mirror 8/13] lvconvert to stack a temporary resync mirror on addition
In-Reply-To: <476AA7BC.9080708@ce.jp.nec.com>
References: <476AA7BC.9080708@ce.jp.nec.com>
Message-ID: <476AAE71.3020705@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow lvconvert to add mirror by inserting a "_resync<n>" layer
and add mirrors to it.

FIXME: Limited to corelog. It'll be fixed with later patches.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-add-mirror.patch
Type: text/x-patch
Size: 1744 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071220/c0cf5df9/attachment.bin>
