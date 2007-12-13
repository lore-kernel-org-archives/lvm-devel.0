From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:31:46 -0500
Subject: [PATCH lvconvert 6/6] Add lv_{add,remove}_mirrors()
In-Reply-To: <47619E84.2060905@ce.jp.nec.com>
References: <47619E84.2060905@ce.jp.nec.com>
Message-ID: <4761A4C2.3080501@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds generic wrappers for mirror addition / removal
and changes lvcreate, lvconvert and pvmove to use them.

Mirror addition has 2 modes: MIRROR_BY_SEG and MIRROR_BY_LV.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-generic-lv-add-remove-mirrors.patch
Type: text/x-patch
Size: 7395 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/7094a477/attachment.bin>
