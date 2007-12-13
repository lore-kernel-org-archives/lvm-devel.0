From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 13 Dec 2007 16:04:00 -0500
Subject: [PATCH pvmove 8/9] Change pvmove to use the generalized mirror-removal APIs
In-Reply-To: <476198D3.1080003@ce.jp.nec.com>
References: <476198D3.1080003@ce.jp.nec.com>
Message-ID: <47619E40.6060308@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

remove_pvmove_mirrors() is replaced by generic interfaces.

# The 'FIXME' comment was copied from the original code,
# not newly added.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-pvmove-use-generalized-mirror-removal.patch
Type: text/x-patch
Size: 1036 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071213/9a42601f/attachment.bin>
