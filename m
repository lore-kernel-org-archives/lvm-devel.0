From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 29 Oct 2010 15:34:18 +0200
Subject: [PATCH] let dmeventd unmount invalid snapshots (BZ 189462)
In-Reply-To: <87y69h6wy8.fsf@twilight.int.mornfall.net.>
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>	<87r5g4lejw.fsf@twilight.int.mornfall.net.>	<877hhujgh8.fsf_-_@twilight.int.mornfall.net.>
	<87y69h6wy8.fsf@twilight.int.mornfall.net.>
Message-ID: <4CCACD5A.7040805@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29.10.2010 13:49, Petr Rockai napsal(a):
> Hi again,
> 
> the somewhat delayed re-cast of the auto-umount patch is
> attached. Changes since the last time:
> 
> - the umount itself is now outside the dmeventd lvm2 lock, which should
>   mitigate the deadlock opportunities introduced by the umount
> - we fork & exec real /bin/umount now, meaning that /etc/mtab is updated
>   (well, if umount manages to update it, that is)
> 

Looks like a bit of problem for application which locks itself into memory, to
proceed all the time. Though currently I do not have good solution for this
problem in mind - so it's probably to have at least something in this moment.

Zdenek


