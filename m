From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Apr 2019 12:05:33 +0200
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <CAKM4Aew6OawXaes+whH-0W-aAedR_JMF-ObYtVtowOSUdQQJ_Q@mail.gmail.com>
References: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
	<47346a29-e6c7-6e22-4360-2d07e2ec7be3@redhat.com>
	<CAKM4Aexm31mYW8WDeiZ4shCoysCcGjic8zV0XiVqEVZvKz-ecQ@mail.gmail.com>
	<7839ff52-18e5-6a95-9a2a-12ea73457700@redhat.com>
	<CAKM4AezLrUrXZKA=vKMaRHcij3K6UBZpy-RcVXeUB9Wwfszh7Q@mail.gmail.com>
	<62151b2e-c21a-177e-f66b-e2e08857be17@redhat.com>
	<CAKM4AeyMsmqmF7NHu9-u0-86LnzrHR4Z5xNt0bmfpLJyoDE0Sw@mail.gmail.com>
	<6514b2be-67d7-3dfe-38b9-95e3bb39f55a@redhat.com>
	<CAKM4Aez9H=GuRLK0EDJTwpb7j34tCu1aY4dS5_L4saDGERestg@mail.gmail.com>
	<CAKM4Aew6OawXaes+whH-0W-aAedR_JMF-ObYtVtowOSUdQQJ_Q@mail.gmail.com>
Message-ID: <7b17539c-749c-154f-d777-1d80d562a7f6@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11. 04. 19 v 19:33 Eric Ren napsal(a):
> Hi Zdenek,
> 
>> Anyway - proper reproducer with full -vvvv log would be really the most
>>> explanatory and needed to move on here.
> 
> The activation error is reproduced once more. Please see lvm2.log attached.
> 
> Please search the error message like this:
> 
> $grep -rn Aborting lvm2.log
> ./lvm2.log:1386:activate/dev_manager.c:2459 lvcreate  Aborting.  LV
> mythinpool_tmeta is now incomplete and '--activationmode partial' was
> not specified.
> 
> $grep -rn "Failed to suspend" lvm2.log
> ./lvm2.log:1399:metadata/lv_manip.c:7416 lvcreate  Failed to suspend
> thin snapshot origin vg0/6.
>

Hi

Looking at provided log file - the system seems to be using some weird udev 
rule - which results in generating  strange /dev/__  symlinks.

My assumption can be the udev rule has missed to set some variable properly
so instead of    /dev/xxxx__yyyyy  you end with  /dev/__


There are already visible some other devices like i.e.:

/dev/disk/by-id/virtio-instance-store0___O-part1 pointing to  /dev/vda1


 From log is visible lvm2 wants to actually store metadata on /dev/__
so for some reason thins symlink was preffered over real mknode device.

So the fact there is missing device for _tmeta comes from the fact,
there is probably mess in /dev directory and lvm2 becuase can't cope better 
with this particular case.

IMHO fixing the udev rules should be enough to get things running properly.

Since the log shows tons of 'nbd' device - it could be some race in udev rule 
processing as well.

The selection of preferred name in lvm2 is somewhat out-of-data and now it 
would be probably always better to prefer real node name over any symlink
at the price of less explanatory logging but with higher chance of figure out 
real state of system.

But ATM it's important to figure out how this situation happens.


BTW - you can always setup filter (and you really SHOULD in this case),
to whitelist devices for scanning to avoid similar issues.


I assume you want to set something like   a|/dev/vd|,  r|.*|

Also you should collect udev rules and post them here so we can check
which rule could be suspected.


Regards

Zdenek


