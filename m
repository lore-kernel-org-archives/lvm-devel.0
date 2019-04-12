From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Apr 2019 15:44:18 +0200
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <CAKM4AexgHS64pm8CE4PhToUCL_12j0KzAPV-XJ5HNGxvVn5rSA@mail.gmail.com>
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
	<CAKM4AexgHS64pm8CE4PhToUCL_12j0KzAPV-XJ5HNGxvVn5rSA@mail.gmail.com>
Message-ID: <e1c1f1c2-2717-25cd-e063-50df9df04c4f@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12. 04. 19 v 12:42 Eric Ren napsal(a):
> Hi!
> 
>> Looking at provided log file - the system seems to be using some weird udev
>> rule - which results in generating  strange /dev/__  symlinks.
> 
> Yes! I also see these weird device names, but I don't have a good
> explanation for it, so that I'm stupid to think deep into it.
> Thanks!!!
> 
>> There are already visible some other devices like i.e.:
>>
>> /dev/disk/by-id/virtio-instance-store0___O-part1 pointing to  /dev/vda1
> 
> So, the broken device path/symbol is only related to udev, lvm just
> get the device list from udev DB right?
> 
> Do you think such issue can make LVM think the disk is missing?

Hi

There is very low number of lvm developer and very high number of generated 
different error states from udev ;)

So far we have not though about this one - so we will need to think whether
we can figure out something for these sorts of errors...

IMHO it looks like  /dev/__  symlink in your case occasionally points to 
different device - and this is confusing lvm2
(and resent version even more as they is way more open/close sequences beyond 
the point I'd like to see...)

>> Also you should collect udev rules and post them here so we can check
>> which rule could be suspected.
> 
> Thanks! From this, I've learned how import device filter setup is!

Filters can fix a loooot of trouble we are otherwise having hard times to 
figure out the right sequence....

So whenever you can - set your filter as tight as possible - this will speedup 
execution of any lvm2 command and reduce risk of accessing  unwanted devices...

Regards

Zdenek


