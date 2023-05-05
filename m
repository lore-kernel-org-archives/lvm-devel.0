From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 5 May 2023 17:14:01 +0200
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <b0296010-2505-c636-24cf-4f90a690687a@web.de>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
 <b987f331-b2c8-ed18-14eb-e039830ed436@gmail.com>
 <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
 <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
 <0c82e706-8051-d131-91fb-f8f5556d88e7@web.de>
 <0780dc89-f6b8-e204-18c3-12e404aeaaff@gmail.com>
 <b0296010-2505-c636-24cf-4f90a690687a@web.de>
Message-ID: <56ad4eea-650d-5f29-1d5b-a6278045fa28@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 04. 05. 23 v 18:31 haaber napsal(a):
> Dear Zdenek
>
> On 5/4/23 15:17, Zdenek Kabelac wrote:
>>
>>> lvchange -ay qubes_dom0/pool00_tmeta
>>
>>
>> Looking at your 'lvs -a' output - you should be able to get this one
>> active.
>>
>>
>> You will need another LV to write fixed metadata into
>>
>> # lvcreate -L128M -n newlv? qubes_dom0
>
> He was yelling at me:
>
> # lvcreate -L128M -n newlv? qubes_dom0
>
> ? WARNING: Sum of all thin volume sizes (<1.62 TiB) exceeds the size of
> thin pools and the size of whole volume group (238.27 GiB).
> ? WARNING: You have not turned on protection against thin pools running
> out of space.
> ? WARNING: Set activation/thin_pool_autoextend_threshold below 100 to
> trigger automatic extension of thin pools before they get full.
> ? Logical volume "newlv" created.
>
> But since he seemed to live with it, I gave it a try and continued. So I
> activated tmeta by
>
> lvchange -ay qubes_dom0/pool00_tmeta
>
>>
>> Then you run
>>
>> # thin_repair -i /dev/qubes_dom0/pool00_tmeta -o /dev/qubes_dom0/newlv
>>
> # thin_repair?? -i /dev/qubes_dom0/pool00_tmeta? -o /dev/qubes_dom0/newlv
> terminate called after throwing an instance of 'std::runtime_error'
> ? what():? transaction_manager::new_block() couldn't allocate new block
> Aborted


Yeah this will need? Ming's investigation with raw binary date from your 
metadata volume

(see my 2nd. mail)

Regards


Zdenek



