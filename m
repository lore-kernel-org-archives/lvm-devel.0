From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 21 Dec 2007 20:23:18 -0500
Subject: [PATCH 3/4] Show mirror image sync status in Attr field
Message-ID: <476C6706.2030700@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Since now we can add mirrors to the existing mirrors,
some mirror images are in-sync while other are out-of-sync.

This patch shows the mirror image sync status in Attr field
as volume type character.
'i' used to mean 'mirror image'.
With this patch, 'i' means 'mirror image in-sync'.
'I' means 'mirror image out-of-sync (syncing)'.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: show-sync-state-in-mimage-attr.patch
Type: text/x-patch
Size: 1964 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071221/812046d5/attachment.bin>
