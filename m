From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 30 Aug 2013 11:12:12 +0200
Subject: lvrename changes link to direct /dev/dm-X
In-Reply-To: <52206140.7060204@redhat.com>
References: <521F1A5F.9040805@mglug.de> <52206140.7060204@redhat.com>
Message-ID: <522061EC.6090109@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.8.2013 11:09, Zdenek Kabelac napsal(a):
> Dne 29.8.2013 11:54, Oliver Rath napsal(a):
>> Hi list,
>>
>> I was able to reproduze the renaming issue on a gentoo-machine with lvm-git:
>>
>> heimserver ~ # lvcreate --name myoriginal -V 10M -T dmivg/winthinpool
>>    Rounding up size to full physical extent 12,00 MiB
>>    Logical volume "myoriginal" created
>> heimserver ~ # ls -l /dev/dmivg/myoriginal
>> lrwxrwxrwx 1 root root 28 29. Aug 11:46 /dev/dmivg/myoriginal ->
>> /dev/mapper/dmivg-myoriginal
>
> So Gentoo has broken udev rules as well probably.
> Links created by proper udev rules should be pointing directly to /dev/dm-x
>
>
> Have you been compiling lvm2 yourself ?
>
> Have you configured lvm2 package with --enable-udev_rules?
> (it's not enabled by default)

Sorry - here should be   '--enable-udev_sync'
(And for built-in thin support you also need  '--with-thin=internal')

Zdenek


