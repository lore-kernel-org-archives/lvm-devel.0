From: Oliver Rath <rath@mglug.de>
Date: Fri, 08 Aug 2014 10:51:22 +0200
Subject: vgrename omit renaming hidden volumes if vg is inactive -> thinpools will be inconsistent
In-Reply-To: <53E46D7F.10203@redhat.com>
References: <53E3D623.7040606@mglug.de> <53E46D7F.10203@redhat.com>
Message-ID: <53E48F8A.4060107@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Peter!

Am 08.08.2014 um 08:26 schrieb Peter Rajnoha:
> On 08/07/2014 09:40 PM, Oliver Rath wrote:
>> Hi list,
>>
>> ive probably found a bug in lvm2 (testet on commit hash
>> 6320c3b9052004397faf1687198756ac7914fecc):
>>
>> if i rename an inactive vg (vgchange -an vg), then the hidden volumes
>> like /dev/mapper/vg-mypool_tdata ..tmeta ..tpool arent renamed in
>> /dev/mapper/..
>>
> Inactive VG should not have any /dev/ content. If it remained after
> deactivation, it seems to be a bug in node/symlink handling under /dev.
>
> A few questions then:
>
>   - what distro is this?
Ubuntu 14.04.1 Server amd64 + ubuntu-desktop + lvm2-2.02.106 from git +
thin-provisioning-tools-0.3.2 from git

>   - are you using udev rules from lvm2 git repo too?
Yes
>   - what are the lvm.conf values for these settings:
>       - activation/udev_sync
yes
>       - activation/udev_rules
yes
>       - activation/verify_udev_operations
yes
>   - what udev (or systemd+udev) version is being used
>   - are all the items found in /dev/mapper symlinks (not direct block dev nodes)?
>   - are there dangling symlinks found in /dev/mapper for the LVs from deactivated VG?
>
udev-204-5ubuntu2

Im using thinpool-devices from a 700MB thinpool-device.

If you need more, tell me!

Tfh
Oliver


