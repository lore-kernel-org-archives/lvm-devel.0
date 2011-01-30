From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 22:10:28 +0100
Subject: [PATCH 02/24] Replace PV_MIN_SIZE with function pv_min_size()
In-Reply-To: <4D45C897.3040705@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>	<10a41c93f0c3f21e0ed40a74184001ca6b51bd19.1296391340.git.zkabelac@redhat.com>	<4D45C3AF.7010702@redhat.com>
	<4D45C6F3.5000000@redhat.com> <4D45C897.3040705@redhat.com>
Message-ID: <4D45D3C4.600@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.1.2011 21:22, Milan Broz napsal(a):
> On 01/30/2011 09:15 PM, Zdenek Kabelac wrote:
> 
>> i.e. if you configure pv_min_size = 10MB - you cannot create  smaller PV - as
>> it would be invisible in your system - IMHO it could eventually lead to bigger
>> confusion - you create small PV, which will be invisible for lvm tools...
>>
>> If you want to create and see smaller PV - lvm.conf needs to be set to smaller
>> value.
> 
> How it differs from filters line in principle?
> 
> If you want to see device, you have to set filer properly.
> 
> Of course it will prevent pv creation, because device is filtered out,
> but on another level.


That's the purpose - to be a very simple and universal filter - to remove such
devices out of any touch by any lvm scanning code (see RHBZ 644578).

You could create complicated lvm.conf per each host - to handle small local
block devices (FDD or whatever you could be attached these days on USB
and present itself as a small storage device /dev/sdX) and allow to support
only larger drives by some smart regex patters unique to each host - or you
could use this simple option to allow LVM only for devices which are i.e. 10GB
in size minimum.


IMHO added new 'filter' config option would just add code like this:

if (dev_size < pv_min_size) goto err;
if (dev_size < configure_pv_min_size) goto err;

With the advantage to pvcreate or pvresize to get 'invisible' devic as it
would be filtered out for any further usage.

Zdenek


