From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 06 Dec 2007 11:48:57 -0500
Subject: [PATCH pvmove 2/6] Add convert_segments_mirrored()
In-Reply-To: <475825EF.6000803@ce.jp.nec.com>
References: <475825EF.6000803@ce.jp.nec.com>
Message-ID: <475827F9.7030706@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add convert_segments_mirrored().

The function converts each segment in the LV to mirrored.

This is a generalized version of add_pvmove_destinations()
in the previous patchset:
https://www.redhat.com/archives/lvm-devel/2007-November/msg00036.html

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-convert-segments-mirrored.patch
Type: text/x-patch
Size: 5926 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071206/bcf07cf0/attachment.bin>
