From: Xinwei Hu <hxinwei@gmail.com>
Date: Mon, 28 Feb 2011 17:37:08 +0800
Subject: pvmove hangs while operating with heavy I/O stress
Message-ID: <AANLkTikVTcY-jzorzUt9tsJqto1e7GWksJxvKRobsM8K@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,
  When there're several LVs on $PV1, and there is heavy I/O on several LVs,
"pvmove $PV1 $PV2" may hang forever in suspend_lv.
  This is because suspend_lvs iterates the list of LVs, and suspends them all.
While suspend_lv has already suspend the underlying mirror table, following
suspend_lv may sleep forever, waiting for IO flushing.

  The attached patch is a direct attack the problem. But it may be better to
fix suspend_lvs directly.

  Any comments ?

  Thanks.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: pvmove-fix.patch
Type: text/x-patch
Size: 2346 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110228/22afddb4/attachment.bin>
