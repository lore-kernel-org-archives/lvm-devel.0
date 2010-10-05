From: Petr Rockai <prockai@redhat.com>
Date: Tue, 05 Oct 2010 19:44:51 +0200
Subject: [PATCH] automatic snapshot extension with dmeventd (BZ 427298)
In-Reply-To: <87lj6cn3wz.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Tue, 05 Oct 2010 15:51:40 +0200")
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>
Message-ID: <87r5g4lejw.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Attaching a revised patch, addressing couple of points raised on IRC by
Alasdair. The setting names have changed, I have cleaned up defaults to
use the standard mechanism and fixed couple of coding style points.

The tests still pass.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-snapshot-extend.diff
Type: text/x-diff
Size: 15449 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101005/7be9778e/attachment.bin>
