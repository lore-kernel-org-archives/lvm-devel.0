From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Thu, 4 May 2023 15:17:53 +0200
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <0c82e706-8051-d131-91fb-f8f5556d88e7@web.de>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
 <b987f331-b2c8-ed18-14eb-e039830ed436@gmail.com>
 <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
 <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
 <0c82e706-8051-d131-91fb-f8f5556d88e7@web.de>
Message-ID: <0780dc89-f6b8-e204-18c3-12e404aeaaff@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 03. 05. 23 v 18:48 haaber napsal(a):
> Dear Zdenek,
>
> I had a forced break, but the subject is still active..
>
>>
>> To get to your thin-pool metadata, you have to activate LV with them.
>> (lvchange -ay? vgname/thinpoolmetadata).
>>
> my pool is called? qubes_dom0/pool00 (now you know my previous operating
> system :) So I tried
>
> lvchange -ay? qubes_dom0/thinpoolmetadata
>
> but that fails: ? Failed to find logical volume
> "qubes_dom0/thinpoolmetadata"
>
> Then I tried
>
> lvchange -ay qubes_dom0/pool00_tmeta


Looking at your 'lvs -a' output - you should be able to get this one active.


You will need another LV to write fixed metadata into

# lvcreate -L128M -n newlv? qubes_dom0


Then you run

# thin_repair -i /dev/qubes_dom0/pool00_tmeta -o /dev/qubes_dom0/newlv

If you get some repaired set? which you could probably validate with

 ?# thin_dump?? /dev/qubes_dom0/newlv

if you will some some 'good amount' of some data which describe block mapping 
for many thin volumes.

However if you only see couple lines - basically empty thin-pool metadta - you 
will need to store the content of your original unmodified metadata into a 
compressed file and upload the file for futher exploration.

Let me know what you get from those steps above.


Zdenek



