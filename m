From: Oliver Rath <rath@mglug.de>
Date: Fri, 30 Aug 2013 11:30:58 +0200
Subject: lvrename changes link to direct /dev/dm-X
In-Reply-To: <52206140.7060204@redhat.com>
References: <521F1A5F.9040805@mglug.de> <52206140.7060204@redhat.com>
Message-ID: <52206652.5070608@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek!

Am 30.08.2013 11:09, schrieb Zdenek Kabelac:
> [..]
> So Gentoo has broken udev rules as well probably.
> Links created by proper udev rules should be pointing directly to
> /dev/dm-x
>
>
> Have you been compiling lvm2 yourself ?

Yes, I compiled it myself. There is no ebuild for git at the moment.

>
> Have you configured lvm2 package with --enable-udev_rules?
> (it's not enabled by default)

No, I dont. Thank you for the hint. I will try that.

>
> Isn't there any udev falback running in this system ?

I dont know, what udev fallback is. Where do I have to look?

>
> Isn't device activated without udev?

AFAIK udev is always running. I can make a try generating lvm-devices
without a running udevd.


>
> In pre-udev  era all dm nodes have been created in /dev/mapper subdir.
> So lvm created links pointing to this place.
>
> With  udev  all dm nodes are by default created as  /dev/dm-xx and all
> the links in /dev/mapper & /dev/vgname/lvname  are pointing directly
> to this node - but that require proper udev rules and properly
> configured system -  I'd recommend  to test with i.e. Fedora.
ok
>
> Unfortunately systems like Debian are using non-upstream udev rules
> from maintainer which are reinventing them based on some unknown rules
> to us...
ok
>
>
>> heimserver ~ # lvrename /dev/dmivg/myoriginal myrenamedoriginal
>>    Renamed "myoriginal" to "myrenamedoriginal" in volume group "dmivg"
>> heimserver ~ # ls -l /dev/dmivg/myrenamedoriginal
>> lrwxrwxrwx 1 root root 8 29. Aug 11:47 /dev/dmivg/myrenamedoriginal ->
>> ../dm-13
>> heimserver ~ # ls -l /dev/mapper/dmivg-myrenamedoriginal
>> lrwxrwxrwx 1 root root 8 29. Aug 11:47
>> /dev/mapper/dmivg-myrenamedoriginal -> ../dm-13
>>
>>
>> It seems, that after renaming the link points directly to the /dev/dm-X
>> device, before that he linked to the link in /dev/mapper/..
>
> Well as long as the point to the proper device at the end - it's at
> least usable - but it's clear the udev dir has been probably touched
> by fallback rules (which are there for cases, udev is failing to do
> proper thing)

Yes, thats a point: it still useable. But these broken rules can create
really strange results of linking an, if you are using the link-names
semanticly like me, you can run into serious problem although.
>
>
>> root at asterisk:~# ls -l /dev/mapper/dmivg-myoriginal
>> lrwxrwxrwx 1 root root 8 Aug 29 11:50 /dev/mapper/dmivg-myoriginal ->
>> ../dm-55
>> root at asterisk:~# lvrename /dev/dmivg/myoriginal myrenamedoriginal
>>    Renamed "myoriginal" to "myrenamedoriginal" in volume group "dmivg"
>>    Unable to rename device node from 'dmivg-myoriginal' to
>
> Udev rules are not doing what they supposed to do....
Ok

>
>> 'dmivg-myrenamedoriginal'
>> root at asterisk:~# ls -l /dev/dmivg/myrenamedoriginal
>> lrwxrwxrwx 1 root root 35 Aug 29 11:51 /dev/dmivg/myrenamedoriginal ->
>> /dev/mapper/dmivg-myrenamedoriginal
>> root at asterisk:~# ls -l /dev/mapper/dmivg-myrenamedoriginal
>> brw------- 1 root root 252, 55 Aug 29 11:51
>> /dev/mapper/dmivg-myrenamedoriginal
>> root at asterisk:~#
>>
>> Here the device twice: in /dev/dm-55 _and_ in
>> /dev/mapper/dmivg-myrenamedoriginal
>>
>> @Zdenek: if you need a -vvvv log, please tell me.
>
> If you have been compiling lvm2 yourself - you could replace upstream
> rules with those placed in Debian.
Im using debian (ubuntu) rules at the moment. Will try your
upstream-rules by configuring --with-thin=internall --enable-udev_sync
--enable-udev_rules

>
> I guess the only real solution here would be to build Debian package
> by some lvm2 team member since the package in Debian is probably broken.

This would be a great thing because the actual lvm-packages are really,
really outdated.

I will give you report of my results.

Tfh!
Oliver


