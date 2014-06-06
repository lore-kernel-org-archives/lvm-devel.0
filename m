From: Liuhua Wang <lwang@suse.com>
Date: Fri, 06 Jun 2014 01:26:47 -0600
Subject: [PATCH] clvmd: fix _allocate_memory to avoid segfault on ppc64.
In-Reply-To: <539167C2.2060604@redhat.com>
References: <1402037364-7417-1-git-send-email-lwang@suse.com>
	<539167C2.2060604@redhat.com>
Message-ID: <5391DDB7020000A000008149@soto.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


>>> On 6/6/2014 at 03:03 PM, in message <539167C2.2060604@redhat.com>, Zdenek
Kabelac <zkabelac@redhat.com> wrote: 
> Dne 6.6.2014 08:49, Liuhua Wang napsal(a):
> > From: lhwang <lwang@suse.com>
> >
> > Under some LIBPTHREAD_VERSION, for example 2.11, when allocates 64K
> > and thread stacksize is 128K, starting clvmd causes a segfault.
> >
> > Signed-off-by: Liuhua Wang <lwang@suse.com>
> 
> Do you have any stack backtrace for this situation.
> 
> It'd be rather serious problem in clvmd code path to allocate even 32K on 
> stack.
> 
> Thanks
> 
> Zdenek
> 

version: 2.02.98-0.25.4 

from the core file:

#p $pc
$1 = (void (*)()) 0x10070c18
#bt
#0  0x0000000010070c18 in _allocate_memory () at mm/memlock.c:130
#1  0x0000000010070d38 in _lock_mem (cmd=<optimized out>) at mm/memlock.c:310
#2  _lock_mem_if_needed (cmd=0x10104f40) at mm/memlock.c:387
#3  0x0000000010011358 in init_clvm (excl_uuid=<optimized out>) at
lvm-functions.c:919
#4  0x000000001000f47c in lvm_thread_fn (arg=0xfffcaf4e530) at clvmd.c:2020
#5  0x00000fff9df6c67c in .start_thread () from /lib64/power6/libpthread.so.0
#6  0x00000fff9de7643c in .__clone () from /lib64/power6/libc.so.6


Thanks for your reply.

Best regards
Liuhua




> 




