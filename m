From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 20 Dec 2007 13:02:46 -0500
Subject: [PATCH mirror 2/13] Misc fixes to the 'lvconvert' generalization
In-Reply-To: <476AA7BC.9080708@ce.jp.nec.com>
References: <476AA7BC.9080708@ce.jp.nec.com>
Message-ID: <476AAE46.8020800@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This small patch contains misc fixes to the lvconvert generalization
code that has been just committed to CVS.

  - lv_add_mirror_lvs() should turn off VISIBLE_LV flag of
    each mimage LV.
  - 'struct alloc_handle' declaration in metadata-exported.h
    is not needed as create_mirror_layers() was removed.
  - lv_remove_mirrors() should use lv_mirror_count() instead of
    seg->area_count.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lv_add_mirror-fixups.patch
Type: text/x-patch
Size: 2042 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071220/168c4546/attachment.bin>
