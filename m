From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 11 Feb 2008 16:22:11 -0500
Subject: [PATCH lvconvert] Check if polling is needed if the number of mirrors is specified
Message-ID: <47B0BC83.1080602@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvconvert restarts the polling of the conversion check
if no action is specified.

It should behave in the same manner if the number of mirrors given
by '-m' is the same as it has.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-lvconvert-check-for-completion-if-no-action-specified.patch
Type: text/x-patch
Size: 1045 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080211/a33c9620/attachment.bin>
