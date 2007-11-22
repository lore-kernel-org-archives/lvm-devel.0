From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 21:09:17 -0500
Subject: [PATCH mirror 6/13] Count the correct number of mirror images
In-Reply-To: <4744DF34.7090701@ce.jp.nec.com>
References: <4744DF34.7090701@ce.jp.nec.com>
Message-ID: <4744E4CD.7050205@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If temporary mirror layers are inserted, you can't get
the number of mirror images by seg->area_count.

The patch adds a function to recursively sum up the number
of mirror images.
Used later by lvconvert and reporting functions.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-count-legs.patch
Type: text/x-patch
Size: 1561 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/539d1cd3/attachment.bin>
