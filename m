From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 21:08:28 -0500
Subject: [PATCH mirror 1/13] Enable mirror-addition to lvconvert
In-Reply-To: <4744DF34.7090701@ce.jp.nec.com>
References: <4744DF34.7090701@ce.jp.nec.com>
Message-ID: <4744E49C.6060902@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch allows lvconvert to add mirror to mirrored LV.

If mirrors are added to mirrored LV, a temporary layer will
be inserted for resync new mirrors.
The temporary LV is under the same naming rule with mirror images.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-add-mirror.patch
Type: text/x-patch
Size: 4023 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/4a7f1e47/attachment.bin>
