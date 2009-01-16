From: Bryn M. Reeves <bmr@redhat.com>
Date: Fri, 16 Jan 2009 18:30:21 +0000
Subject: iSCSI logout hangs LVM
In-Reply-To: <1232128968.14288.33.camel@localhost.localdomain>
References: <496EC869.2060803@nrel.colostate.edu>
	<1232128968.14288.33.camel@localhost.localdomain>
Message-ID: <4970D23D.7030303@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski wrote:
> On Wed, 2009-01-14 at 22:23 -0700, Ty! Boyack wrote:
>> This is all being done on a Fedora 9 boxes with updated packages:
>> lvm2-2.02.33-11.fc9.x86_64
>> iscsi-initiator-utils-6.2.0.870-1.0.fc9.x86_64
>> device-mapper-1.02.24-11.fc9.x86_64
>> udev-124-2.fc9.x86_64
>> kernel-2.6.27.9-73.fc9.x86_64
>>
>> I would appreciate any thoughts or suggestion on this!
>>
> 
> You need to make sure iscsi and multipath are setup properly to
> eventually fail the IO.  I believe the README and/or config files in
> these projects describe the settings needed.

Or remove the multipath maps for these devices *before* logging out of 
the target. This is a common mistake with multipath - when you're 
removing storage, the ordering should normally be:

- unmount file systems / stop applications using the device
- flush multipath map(s) (-f/-F)
- remove underlying path devices (iSCSI logout etc)

If this isn't possible, there's a feature in the RHEL builds of 
multipath-tools named "flush_on_last_del" which may help you here. It 
will disable queueing for the multipath target when the last path to 
it disappears, preventing I/O from hanging forever on the missing devices.

Regards,
Bryn.



