From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 24 Apr 2014 10:08:52 +0200
Subject: clvmd coredump issue
In-Reply-To: <535926B2020000A000005EB1@soto.provo.novell.com>
References: <535926B2020000A000005EB1@soto.provo.novell.com>
Message-ID: <5358C694.4060807@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 24.4.2014 08:58, Liuhua Wang napsal(a):
> Hi, list
>
> I have encountered a coredump when start clvmd on ppc64 as followed:
>
> #p $pc
> $1 = (void (*)()) 0x10070c18
> #bt
> #0  0x0000000010070c18 in _allocate_memory () at mm/memlock.c:130
> #1  0x0000000010070d38 in _lock_mem (cmd=<optimized out>) at mm/memlock.c:310
> #2  _lock_mem_if_needed (cmd=0x10104f40) at mm/memlock.c:387
> #3  0x0000000010011358 in init_clvm (excl_uuid=<optimized out>) at
> lvm-functions.c:919
> #4  0x000000001000f47c in lvm_thread_fn (arg=0xfffcaf4e530) at clvmd.c:2020
> #5  0x00000fff9df6c67c in .start_thread () from /lib64/power6/libpthread.so.0
> #6  0x00000fff9de7643c in .__clone () from /lib64/power6/libc.so.6
>
>
> When the followed four lines are commented then the problem is ok.
> I suppose the problem is probably because of alloca.
>
> static void _allocate_memory(void)
> {
> 	void *stack_mem, *temp_malloc_mem;
> 	struct rlimit limit;
>
> 	/* Check if we could preallocate requested stack */
> -	if ((getrlimit (RLIMIT_STACK, &limit) == 0) &&
> -	    ((_size_stack * 2) < limit.rlim_cur) &&
> -         ((stack_mem = alloca(_size_stack))))
> -	   _touch_memory(stack_mem, _size_stack);
> 	/* FIXME else warn user setting got ignored */
>
> 	if ((temp_malloc_mem = malloc(_size_malloc_tmp)))
> 		_touch_memory(temp_malloc_mem, _size_malloc_tmp);
>
> 	if ((_malloc_mem = malloc(_size_malloc)))
> 		_touch_memory(_malloc_mem, _size_malloc);
>
> 	free(temp_malloc_mem);
> }
>
> My questions are:
> 1. Can we delete the four lines, since it is just PREallocate?
> 2. What is the purpose of _touch_memory()
> 3. why do first malloc temp_malloc_mem but then free it?
>
> Any information is very appreciated.

The memory use in lvm2 has deeper logic.

The idea behind preallocation and touching memory is - to preallocate memory 
pages and enforce their physical allocation for stack & heap - before the 
memory is mlock()-ed into RAM.

Since the suspend may free i.e. swap device - all the code parts which run in 
suspend needs to be locked in RAM.

Now back to powerpc issue - check why it's crashing -  is the rlim_cur  wrong?
Stack size is too big ?

Code will not be removed it needs to be fixed for powerpc.

Zdenek



