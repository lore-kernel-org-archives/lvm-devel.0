From: Petr Rockai <prockai@redhat.com>
Date: Mon, 14 Feb 2011 19:41:11 +0100
Subject: [PATCH] lv_postorder bug (fails to clear temporary flags)
Message-ID: <87y65iv4qg.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Milan discovered that running _lv_postorder twice in a row fails to work
properly, due to uncleared postorder flags. This patch should fix the
problem.

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lv-postorder.diff
Type: text/x-diff
Size: 1983 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110214/5cd81d60/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
