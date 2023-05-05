From: Ming Hung Tsai <mtsai@redhat.com>
Date: Fri, 5 May 2023 17:42:15 +0800
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <6c1b291d-b4e4-4698-b9b4-63c43e9e484d@web.de>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
 <b987f331-b2c8-ed18-14eb-e039830ed436@gmail.com>
 <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
 <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
 <0c82e706-8051-d131-91fb-f8f5556d88e7@web.de>
 <0780dc89-f6b8-e204-18c3-12e404aeaaff@gmail.com>
 <6c1b291d-b4e4-4698-b9b4-63c43e9e484d@web.de>
Message-ID: <CALjSBEvobNgcycoivTCq5xr6i5b_=Y9+WQ7BD5KSZawqDtGFRg@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

The thin_dump output looks fine, so I would like to know why there's error
messages emitted. Could you help provide the raw metadata dump please? Just
'dd' the entire '/dev/qubes_dom0/pool00_tmeta' into a file, then upload the
compressed file.


Thanks,
Ming-Hung Tsai

On Fri, May 5, 2023 at 1:07?AM haaber <haaber@web.de> wrote:

> Dear Zdenek,
>
> here https://we.tl/t-41PiPG2V1G     is the output of
>
> #thin_dump   /dev/qubes_dom0/pool00_tmeta  > pool00_tmeta
>
> metadata contains errors (run thin_check for details).
>
> perhaps you wanted to run with --repairmetadata contains errors (run
> thin_check for details).
>
> perhaps you wanted to run with --repair
>
>
> best, Bernhard
>
>
>
>
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://listman.redhat.com/mailman/listinfo/lvm-devel
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230505/c1dec7d8/attachment.htm>
