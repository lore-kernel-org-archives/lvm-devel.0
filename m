From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 21:08:36 -0500
Subject: [PATCH mirror 2/13] Add _apply_lv_change() to lib/metadata/mirror.c
In-Reply-To: <4744DF34.7090701@ce.jp.nec.com>
References: <4744DF34.7090701@ce.jp.nec.com>
Message-ID: <4744E4A4.90700@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is a cosmetic change of moving idiomatic operations of
vg write/lv suspend/vg commit/lv resume to a new function.
No functional change.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-mirror-apply_lv_change.patch
Type: text/x-patch
Size: 2429 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/0c6c55ad/attachment.bin>
