From: Eric Ren <renzhengeek@gmail.com>
Date: Fri, 12 Apr 2019 18:42:40 +0800
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <7b17539c-749c-154f-d777-1d80d562a7f6@redhat.com>
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
	<7b17539c-749c-154f-d777-1d80d562a7f6@redhat.com>
Message-ID: <CAKM4AexgHS64pm8CE4PhToUCL_12j0KzAPV-XJ5HNGxvVn5rSA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!

> Looking at provided log file - the system seems to be using some weird udev
> rule - which results in generating  strange /dev/__  symlinks.

Yes! I also see these weird device names, but I don't have a good
explanation for it, so that I'm stupid to think deep into it.
Thanks!!!

> There are already visible some other devices like i.e.:
>
> /dev/disk/by-id/virtio-instance-store0___O-part1 pointing to  /dev/vda1

So, the broken device path/symbol is only related to udev, lvm just
get the device list from udev DB right?

Do you think such issue can make LVM think the disk is missing?

> BTW - you can always setup filter (and you really SHOULD in this case),
> to whitelist devices for scanning to avoid similar issues.
>
>
> I assume you want to set something like   a|/dev/vd|,  r|.*|
>
> Also you should collect udev rules and post them here so we can check
> which rule could be suspected.

Thanks! From this, I've learned how import device filter setup is!

Regards,
Eric



-- 
- Eric Ren


