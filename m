From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 3 Mar 2016 11:32:12 +0100
Subject: directory instead of link for thinpools?
In-Reply-To: <56D80F3A.4010700@mglug.de>
References: <56D80F3A.4010700@mglug.de>
Message-ID: <56D812AC.9020600@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 3.3.2016 v 11:17 Oliver Rath napsal(a):
> Hi list,
>
> Im using thinpool-devices for a longer time (3+ years) and thinking
> about a more intuitive representation in /dev/.
>
> If Im right, Thinpools are not used directly (as device), only as pool
> for thinpool-based devices (these with --virtualsize instead of --size).
>
> I.e. we are using "vg" as volumegroup and "pool" as thinpool,
> "pooldevice" a "pool" based virtual device and "standarddevice" a normal
> (non-thinpool) lvm-device, then following happens:
>
> - /dev/vg/pool is a link to /dev/dm-X, which is a device node, but never
>    used directly
> - /dev/vg/pooldevice is also a link to /dev/dm-Y, but now it is useable
>    directly
> - /dev/vg/standarddevice is also a link to /dev/dm-Z, useable directly,
>    but not snappable like thinpool devices
>
> This is imho a bit confusing.
>
> My idea now would be to change the representation of "pool" from a link
> to this (never directly used) device to a directory, which includes the
> links to the pooldevices. Now the representation would look like this
> ("/" is dir, "@" is link):
>
> /dev/vg/standarddevice@
> /dev/vg/pool/
> /dev/vg/pool/pooldevice@
>
>
> Now I tried to create this with udev-rules, but unfortunatly I didnt
> find any possibility to differ between standarddevices, pools and
> pool-based devices. Is there any possibility to recogize this for
> udev-rules?
>
> What do you think generally about this idea?
>

Hi

NACK

It's already complex with existing udev & system rules - so adding new 
complicated stuff makes no sense.

If you need to get some 'visually' similar layout - just prepend
pool name prefix into your  LV name.

But there is not going to be subdir support for LVs in lvm2.

It stays with simple rule: user usable LV has device path:

/dev/vgname/lvname

and thinLV is user usable LV  and we are not going change this key rule.

Regards

Zdenek




