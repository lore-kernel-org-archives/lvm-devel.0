From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:45:19 -0500
Subject: [PATCH 3/11] Move mirror log initialization functions
In-Reply-To: <4787FA27.8050300@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com>
Message-ID: <4787FF8F.2000000@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move mirror log initialization functions to the earlier part of the file.
No functional change.

_init_mirror_log() will be used by _remove_mirror_images(),
when it wants to reset the log contents for reconfigured mirror.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: cosmetic-move-log-function-to-head.patch
Type: text/x-patch
Size: 7475 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/daa659a5/attachment.bin>
