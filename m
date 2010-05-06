From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 06 May 2010 19:42:47 -0400
Subject: [RFC PATCH] Reduce noise about missing devices.
In-Reply-To: <20100505190119.GF27027@agk-dp.fab.redhat.com>
References: <87k4rsa8fd.fsf@twilight.int.mornfall.net.>
	<20100505190119.GF27027@agk-dp.fab.redhat.com>
Message-ID: <4BE353F7.3040305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/05/10 15:01, Alasdair G Kergon wrote:
> On Tue, Apr 27, 2010 at 11:32:06PM +0200, Peter Rockai wrote:
>> this is not intended to be directly applied, but more to start a
>> discussion. One problem with our handling of missing devices is the huge
>> amount of log noise each missing device produces. In a single run of
>> lvconvert --repair, I get multiple screens of "read error" and "Couldn't
>> find device with uuid"...
>  
> Well my first question before suppressing messages would be: Are all the
> repeated accesses that generate the messages actually necessary?
> Or are the messages just a symptom of other problems which should be
> addressed instead?

I checked how many times a broken device was accessed by the lvconvert
command when 'lvconvert --repair' is executed using the following lvm
environment:

  VG: 3PVs
  LV: mirror composed of 2 legs and 1 disk log

  vg00-lv00 (253:3)
   |-vg00-lv00_mimage_1 (253:2)
   |  `- (8:48)
   |-vg00-lv00_mimage_0 (253:1)
   |  `- (8:32)
   `-vg00-lv00_mlog (253:0)
      `- (8:64)

When a primary leg is broken, 'lvconvert --repair' accesses the primary
leg by '47 times.' I think what we should do is to suppress 'access to
a broken device' instead of suppressing 'displaying error messages.'

Suppress error messages might be friendly to some users, but other users
might not notice how often a broken device is accessed by the lvconvert
command.

Do we need to access a broken device so many times? If lvm commands
detects errors on a device a few times, my opinion is that lvm
commands should quit accessing the device.

Thanks,
Taka


