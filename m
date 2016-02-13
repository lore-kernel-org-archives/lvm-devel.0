From: Brendan Heading <brendanheading@gmail.com>
Date: Sat, 13 Feb 2016 21:19:56 +0000
Subject: MUSL fun
In-Reply-To: <56BF99FF.1030900@redhat.com>
References: <CA+BsyQ4tDvVFXyo2Po9jiFKVobaJhMy7PoxWjczT8KFK9BrXWQ@mail.gmail.com>
	<1ca4pcxqnk.ln2@ID-313208.user.individual.net>
	<CA+BsyQ6ihax71VER=dgCHF-eV0mfjYqZo6LixK21BVrMCGb-Bg@mail.gmail.com>
	<56BF99FF.1030900@redhat.com>
Message-ID: <CA+BsyQ53DooiSj+wErGhM+PemjA7=fKtEBcGHJVmR++tOMo-XQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> commands/toolcontext.c: In function 'create_toolcontext':
> commands/toolcontext.c:1796:10: error: assignment of read-only variable
> 'stdin'
>     stdin = new_stream;
> --
>
> So now - from where comes the idea  of  'stdin' being read-only variable ?
> Looking at some POSIX spec e.g.:
> http://pubs.opengroup.org/onlinepubs/009695399/functions/stdin.html
>
> there is no sign of having this read-only var.
>
> So what kind of OS this actually is ?

musl's rather conservative interpretation appears to be that since the
values of stdin, stdout and stderr are explicitly defined by POSIX, it
is implicit that the variables holding these values should be const.

http://www.openwall.com/lists/musl/2013/03/18/1

There's not a lot of point in debating the rights or wrongs of this.
If it were me, I'd take a pragmatic approach, and if it were me I'd
make this a configurable option, but this defeats musl's stated
objectives and they won't accept a patch to change it.

> There is a reason from lvm2 implementation here - freopen() is not giving
> application full control over internal buffer allocation and we need to be
> sure we lock-in memory for critical section - and some glibc versions are
> allocating buffers here via 'mmap' call.
>
> That said - there could be accepted a patch checking in configure  for
> 'read-only' stdin  - and using then #ifdef compilation that would
> replace use of  internal lvm2 reopen code with libc function.

I had a suspicion you would have a good reason.

On first glance your proposal sounds like a good compromise and one
that would be worth exploring.

Brendan


