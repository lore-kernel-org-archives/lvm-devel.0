From: Petr Rockai <prockai@redhat.com>
Date: Fri, 29 Oct 2010 14:44:15 +0200
Subject: [PATCH] let dmeventd unmount invalid snapshots (BZ 189462)
In-Reply-To: <87y69h6wy8.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Fri, 29 Oct 2010 13:49:03 +0200")
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>
	<87r5g4lejw.fsf@twilight.int.mornfall.net.>
	<877hhujgh8.fsf_-_@twilight.int.mornfall.net.>
	<87y69h6wy8.fsf@twilight.int.mornfall.net.>
Message-ID: <87sjzp6ue8.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai <me@mornfall.net> writes:
> the somewhat delayed re-cast of the auto-umount patch is attached.
... and now a version that addresses Alasdair's IRC comments.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-snapshot-umount.diff
Type: text/x-diff
Size: 6905 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101029/bbf49bc8/attachment.bin>
