From: Petr Rockai <me@mornfall.net>
Date: Fri, 29 Oct 2010 13:49:03 +0200
Subject: [PATCH] let dmeventd unmount invalid snapshots (BZ 189462)
In-Reply-To: <877hhujgh8.fsf_-_@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Thu, 07 Oct 2010 15:10:43 +0200")
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>
	<87r5g4lejw.fsf@twilight.int.mornfall.net.>
	<877hhujgh8.fsf_-_@twilight.int.mornfall.net.>
Message-ID: <87y69h6wy8.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again,

the somewhat delayed re-cast of the auto-umount patch is
attached. Changes since the last time:

- the umount itself is now outside the dmeventd lvm2 lock, which should
  mitigate the deadlock opportunities introduced by the umount
- we fork & exec real /bin/umount now, meaning that /etc/mtab is updated
  (well, if umount manages to update it, that is)

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-snapshot-umount.diff
Type: text/x-diff
Size: 6614 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101029/94d4053b/attachment.bin>
