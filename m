From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Aug 2013 11:20:27 +0200
Subject: lvm-git doesnt set links
In-Reply-To: <521CD4A6.1050802@mglug.de>
References: <521CD4A6.1050802@mglug.de>
Message-ID: <521DC0DB.2050309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.8.2013 18:32, Oliver Rath napsal(a):
> Hi list,
>
> the actual git-snapshot from today seems a bit broken:
>
> If i generate a snapshot from an existing thinpool-device, the device is
> created (visible by lvdisplay), but no softlink will be created, nor in
> /dev/myvg/ neither in /dev/mapper.
>
> Same config like in last mail today.
>
> What happened?
>

By default  thin snapshots are no longer created as active devices.

If you want to create active snapshot -  add option '-K'
(lvcreate -K -s)


You could lvchange this activation behavior.

Zdenek


