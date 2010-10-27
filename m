From: Milan Broz <mbroz@redhat.com>
Date: Wed, 27 Oct 2010 09:45:47 +0200
Subject: [PATCH] Fix a double close() in clvmd (fixing another deadlock bug)
In-Reply-To: <87fwvs1q5z.fsf@twilight.int.mornfall.net.>
References: <87fwvs1q5z.fsf@twilight.int.mornfall.net.>
Message-ID: <4CC7D8AB.10706@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/27/2010 01:37 AM, Petr Rockai wrote:

> - a connection to clvmd is about to finish, let's say the fd is 13 (it
>   often happens to be in my test script, don't ask why)
> - the local_sock thread calls close(13)
> - the lvm thread calls open("/proc/devices"...) and gets 13
> - the main_loop thread calls close(13) [OOPS!]
> - new connection arrives, and is accept'd by a (new) local_sock thread
> - the accept gives an fd of 13 (since it's the lowest free fd at this point)
> - the lvm thread gets around to read from it's /proc/devices
>   handle... 13, again
> - the lvm thread hangs forever trying to read from the socket instead
>   from /proc/devices

Aieeeee. Which fd you want to read today? This sounds so secure... :)

But I still think it is not the real deadlocking problem still...

Anyway, should I build another test rpm with that?

Of course, Ack.

Milan


