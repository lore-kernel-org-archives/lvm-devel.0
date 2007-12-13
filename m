From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:31:40 -0500
Subject: [PATCH lvconvert 5/6] Remove unused mirror functions
In-Reply-To: <47619E84.2060905@ce.jp.nec.com>
References: <47619E84.2060905@ce.jp.nec.com>
Message-ID: <4761A4BC.2060300@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch removes:
  - lv_add_mirror_segment()
       Replaced by lv_add_mirror_lvs()
  - lv_add_more_mirrored_areas()
  - add_mirror_layers()
       These functions were not used.
  - create_mirror_layers()
       Replaced by add_mirror_images()
  - generate_log_name_format()
       "_mlog" hard coding is moved to lib. ("_mimage" has been there.)
  - create_mirror_log()
       Replaced by add_mirror_log()
  - _write_log_header()
       Moved to lib

and renames:
  - _create_layers_for_mirror() -> _create_mimage_lvs()
       This function doesn't create layers but just creates mimage LVs.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-remove-unused-mirror-functions.patch
Type: text/x-patch
Size: 14528 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/bbbfae2c/attachment.bin>
