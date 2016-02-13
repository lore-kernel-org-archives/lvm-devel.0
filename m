From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 13 Feb 2016 22:36:20 +0100
Subject: MUSL fun
In-Reply-To: <CA+BsyQ5Lhvys2eea64T_qE49DaE7gH6QEPsAFi+Nn7VfJ_Ourw@mail.gmail.com>
References: <CA+BsyQ4tDvVFXyo2Po9jiFKVobaJhMy7PoxWjczT8KFK9BrXWQ@mail.gmail.com>
	<1ca4pcxqnk.ln2@ID-313208.user.individual.net>
	<CA+BsyQ6ihax71VER=dgCHF-eV0mfjYqZo6LixK21BVrMCGb-Bg@mail.gmail.com>
	<56BF99FF.1030900@redhat.com>
	<CA+BsyQ53DooiSj+wErGhM+PemjA7=fKtEBcGHJVmR++tOMo-XQ@mail.gmail.com>
	<CA+BsyQ5Lhvys2eea64T_qE49DaE7gH6QEPsAFi+Nn7VfJ_Ourw@mail.gmail.com>
Message-ID: <56BFA1D4.20105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 13.2.2016 v 22:31 Brendan Heading napsal(a):
>>> There is a reason from lvm2 implementation here - freopen() is not giving
>>> application full control over internal buffer allocation and we need to be
>>> sure we lock-in memory for critical section - and some glibc versions are
>>> allocating buffers here via 'mmap' call.
>>>
>>> That said - there could be accepted a patch checking in configure  for
>>> 'read-only' stdin  - and using then #ifdef compilation that would
>>> replace use of  internal lvm2 reopen code with libc function.
>>
>> I had a suspicion you would have a good reason.
>>
>> On first glance your proposal sounds like a good compromise and one
>> that would be worth exploring.
>
> As an alternative idea, what about changing the codebase not to use
> stdin/stdout/stderr, using it's own file descriptor names and calling
> dup2() as appropriate to set them up on startup ?
>
> Just flying the kite - I haven't looked to see how painful this might be.

Hi

Well don't know anyone who would play with this approach which is several 
orders in magnitude more difficult then the plain and simple #ifdef.

I also assume we may probably even overwrite value of stdin via tricky pointer 
magic so compiler will not be able to spot mods of stdin in buildtime.

Regards

Zdenek


