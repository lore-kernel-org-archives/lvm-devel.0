From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:31:26 -0500
Subject: [PATCH lvconvert 2/6] Add add_mirror_images() / {add, remove}_mirror_log()
In-Reply-To: <47619E84.2060905@ce.jp.nec.com>
References: <47619E84.2060905@ce.jp.nec.com>
Message-ID: <4761A4AE.3090406@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add functions to support LV conversion to mirror as whole-lv
  - add_mirror_images()
  - {add,remove}_mirror_log()

write_log_header() and set_lv() are moved/copied from toollib.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-convert-lv-mirrored.patch
Type: text/x-patch
Size: 15937 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/273e4730/attachment.bin>
