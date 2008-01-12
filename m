From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 20:48:03 -0500
Subject: [PATCH 12/14] Do not make extra call to lv_add_user_seg()
In-Reply-To: <4787FF72.9000400@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com> <4787FF72.9000400@ce.jp.nec.com>
Message-ID: <47881C53.9040504@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jun'ichi Nomura wrote:
> As a part of LV stacking support, this patch
> adds a upward link from underlying LV to LV segments
> using the LV.

I'm very sorry. There were some bugs sneaked in the patchst
and I missed them by running tests on unclean tree.

I'm posting 3 additional patches.
[12/14] Do not make extra call to lv_add_user_seg()
[13/14] lvconvert should check first_seg(original_lv)
[14/14] lvconvert help message wasn't fixed to '--wait'

This patch is:

[12/14] Do not make extra call to lv_add_user_seg()
          Without this, lv->segs_using_this_lv will have
          duplicated entry and find_mirror_seg() will fail.
          VG validator will detect it and so most commands
          will not work.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-upward-link.patch
Type: text/x-patch
Size: 861 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/a3c5ff1f/attachment.bin>
