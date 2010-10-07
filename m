From: Petr Rockai <prockai@redhat.com>
Date: Thu, 07 Oct 2010 15:10:43 +0200
Subject: [PATCH] let dmeventd unmount invalid snapshots (BZ 189462)
In-Reply-To: <87r5g4lejw.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Tue, 05 Oct 2010 19:44:51 +0200")
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>
	<87r5g4lejw.fsf@twilight.int.mornfall.net.>
Message-ID: <877hhujgh8.fsf_-_@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is the second part of the snapshot monitoring stuff for
dmeventd. This one will remove mounts of a snapshot when it is
invalidated.

There are some trade-offs involved. I have opted for using an umount
syscall directly since it's simpler and more robust. The downside is
that /etc/mtab will go out of sync and people may actually think that
the snapshot is still mounted (mount(8) just prints mtab without
thinking twice about it). We could just fork off umount(8) instead, but
that can fail in new and interesting ways.

The other possible issue with the patch is that I am not sure whether
it's actually safe to read /proc/mounts incrementally, with possibly
intervening mount/umount calls. It *seems* to be, but a confirmation
would be nice.

The code comes (as usual) with an automated test:
test/t-snapshot-autoumount-dmeventd.sh

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-snapshot-umount.diff
Type: text/x-diff
Size: 4941 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101007/2686b3ab/attachment.bin>
