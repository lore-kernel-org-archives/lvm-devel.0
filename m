From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 21:09:27 -0500
Subject: [PATCH mirror 8/13] Allow removal of mirror images from not-collapsed mirror LV
In-Reply-To: <4744DF34.7090701@ce.jp.nec.com>
References: <4744DF34.7090701@ce.jp.nec.com>
Message-ID: <4744E4D7.3010104@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

remove_mirror_images() is existing function to remove mirror images
from mirrored LV.
This patch changes the function to walk through the mirror layers
to correctly remove mirror images.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-remove-legs.patch
Type: text/x-patch
Size: 3730 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/b4ee06af/attachment.bin>
