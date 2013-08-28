From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 28 Aug 2013 11:31:01 +0200
Subject: lvm-git doesnt set links
In-Reply-To: <521DC0DB.2050309@redhat.com>
References: <521CD4A6.1050802@mglug.de> <521DC0DB.2050309@redhat.com>
Message-ID: <521DC355.9080303@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/28/2013 11:20 AM, Zdenek Kabelac wrote:
> Dne 27.8.2013 18:32, Oliver Rath napsal(a):
>> Hi list,
>>
>> the actual git-snapshot from today seems a bit broken:
>>
>> If i generate a snapshot from an existing thinpool-device, the device is
>> created (visible by lvdisplay), but no softlink will be created, nor in
>> /dev/myvg/ neither in /dev/mapper.
>>
>> Same config like in last mail today.
>>
>> What happened?
>>
> 
> By default  thin snapshots are no longer created as active devices.
> 
> If you want to create active snapshot -  add option '-K'
> (lvcreate -K -s)
> 
> 
> You could lvchange this activation behavior.

...also there's the activation/auto_set_activation_skip
setting in lvm.conf to enable or disable this automatic
skipping of certain LVs on activation (there's a short
comment above that setting that explains it). This setting
is enabled by default.

See also lvcreate/vgchange/lvchange man pages and the documentation
for "-K/--ignoreactivationskip" and "-k/--setactivationskip {y|n}" options.

Peter


