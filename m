From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 22 Jun 2022 11:24:58 +0200
Subject: Fix lvm2 for musl libc
In-Reply-To: <N56haDY--3-2@catcream.org>
References: <N56haDY--3-2@catcream.org>
Message-ID: <11877c24-2fe0-1d77-3cfd-c52d5cc9660d@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 21. 06. 22 v 21:21 cat at catcream.org napsal(a):
> Hi! These patches fix lvm2 for musl.
>
> freopen is used in place of the assignment operator since the standard streams are const in musl. https://www.gnu.org/software/libc/manual/html_node/Standard-Streams.html (it says on this page that the standard streams may not be modifiable on other systems).
>
> The mallinfo patch is just copied from Alpine Linux and it makes _allocate_memory not do anything if glibc isn't used. I don't know if that is fine, and if not I'd probably need some help properly making the function posix compliant, thanks.
>

Hi


Patch for malinfo seems fine, however those? 'freopen()' patches need ome more 
thinking.

We are doing these actions to limit allocation of memory for internal glibc? 
stream buffers.

I'll see what can be done for muslC side - maybe just some ifdef,...


Regards


Zdenek

