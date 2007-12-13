From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:31:31 -0500
Subject: [PATCH lvconvert 3/6] Change lvconvert to use the new mirror APIs
In-Reply-To: <47619E84.2060905@ce.jp.nec.com>
References: <47619E84.2060905@ce.jp.nec.com>
Message-ID: <4761A4B3.6000800@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Change lvconvert to use add_mirror_images() and {add,remove}_mirror_log().

There should be no change in functionality.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvconvert-use-new-mirror-api.patch
Type: text/x-patch
Size: 3330 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/89c4ad28/attachment.bin>
