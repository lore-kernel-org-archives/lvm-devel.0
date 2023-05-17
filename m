From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 May 2023 14:09:41 +0200
Subject: [PATCH] Fix header include for out of tree builds
In-Reply-To: <20230517115038.GE18946@accum.se>
References: <20230516160511.2053800-1-glance@ac2.se>
 <ddfeb159-4148-4aae-7760-0556ca3cda1d@redhat.com>
 <20230517113557.GD18946@accum.se>
 <740f6a11-b7aa-91cc-35c6-3dd39b7d5823@redhat.com>
 <20230517115038.GE18946@accum.se>
Message-ID: <09363fec-dc42-f257-0063-d2bd36d1411e@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 17. 05. 23 v 13:50 Anton Lundin napsal(a):
> On 17 May, 2023 - Zdenek Kabelac wrote:
>
>> Dne 17. 05. 23 v 13:35 Anton Lundin napsal(a):
>>> On 17 May, 2023 - Zdenek Kabelac wrote:
>>>
>>>> Dne 16. 05. 23 v 18:05 Anton Lundin napsal(a):
>>>>> The relative include didn't match up for out of tree builds. The
>>>>> build tree include directory is in the include paths already.
>>>>>
>>>>> Signed-off-by: Anton Lundin <glance@ac2.se>
>>>>> ---
>>>>>
>>>>> Now the following works:
>>>>> $ mkdir lvm2-build
>>>>> $ cd lvm2-build
>>>>> $ ../lvm2/configure
>>>> Hi
>>>>
>>>> Your bug is actually in this command:
>>>>
>>>> configure --srcdir=XXXXX
>>>>
>>>>> $ make
>>>>>
>>>> Otherwise srcdir is located in your builddir and you would actually get more
>>>> errors in various parts of lvmb building - as we tend to use $(srcdir)
>>>> inside makefiles..
>>> I might be misunderstanding you. Are your comment about the fix or the
>>> example on now to trigger the bug?
>>>
>>> Just running configure from another directory will set srcdir
>>> automatically. At least in any kind of modern auto-tools.
>>
>> While we certainly can push this minor change? (and I'll likely push this
>> change upstream with my next changeset) - the usage should be based on
>> srcdir settings - which I'm setting myself for a long time? - as there were
>> always some problems if this was not set properly.
>>
>> So I could try if this got eventually better over time? - but lvm2 is using
>> somewhat hybrid approach - as we only use 'autoconf' but not 'automake'
>> historically.
> With this fix out of tree builds works with or without --srcdir= , and
> if I revert this fix on my local tree the builds fails with or without
> --srcdir= like:
>
> In file included from ../../lvm2/lib/commands/toolcontext.h:21,
>                   from ../../lvm2/lib/integrity/integrity.c:17:
> 				 ../../lvm2/lib/commands/cmd_enum.h:15:10: fatal error:
> 				 ../../include/cmds.h: No such file or directory
> 				    15 | #include "../../include/cmds.h"
>
> //Anton


Can you please provide? corresponding??? 'make V=1' log ?


Zdenek



