From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 13 Sep 2012 11:05:50 +0200
Subject: master - systemd: depend on systemd-udev-settle unit in activation unit
In-Reply-To: <20120912151945.GC3870@nostromo.devel.redhat.com>
References: <20120912093754.2FED74B0E@hosted02.fedoraproject.org>
	<50506DDA.10703@redhat.com> <50507399.3010100@redhat.com>
	<20120912151945.GC3870@nostromo.devel.redhat.com>
Message-ID: <5051A1EE.2040309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/12/2012 05:19 PM, Bill Nottingham wrote:
>> The thing with scsi_wait_scan was only added in the way as
>> an addendum to udev-settle functionality (as the next unit
>> that is executed just after udev-settle).
>>
>> If scsi_wait_scan stayed, then we'd better ask systemd
>> upstream to include the unit with scsi_wait_scan there
>> as an official unit distributed with systemd (but I think
>> they counted with its removal so they did not bother to
>> include it anymore). I haven't inspected where other
>> distros called this scsi_wait_scan in their bootup process,
>> if it was called at all there.
>>
>> As for Fedora, F17 still uses fedora-wait-storage unit
>> (having the modprobe scsi_wait_scan call), F18 and higher
>> still has this unit, but it's failing as the module is not
>> available anymore (the unit will be be removed soon I guess).
>>
>> I think that for upstream solution, it's far better to depend
>> on systemd-udev-settle.service. If there's anything else to
>> wait for besides udev, it should be included in systemd upstream
>> as an official and extra unit (so other distros would take that
>> from systemd upstream when packaging).
> 
> Without scsi-wait-scan, I'm not sure that depending on udev-settle
> will actually gain you much here - udev will have settled while
> background scsi scans are still happening.
> 

Yes, you're right... for older systems where this module is still
present, we should still use the scsi-wait-scan.

However, this is now (at least in Fedora) maintained under
our own initscripts which is not present in all distros I guess.
I'm just trying to point out that it would be better to have
this "fedora-storage-wait" unit in systemd/udev upstream directly
and give it a common name like "storage-wait" which other
storage-related upstream projects could use for reference in
their systemd units if we want to keep it for backward compatibility.

But since the module is now gone, I'm inclined to using systemd-udev-settle
instead and if an update/rebase is needed in packages in older
distro releases, just providing a simple one line patch attached
directly to the build (making use of the original fedora-storage-wait.service).

BTW, just curious, shouldn't we call udev-settle even after
modprobe scsi_wait_scan as well?

Peter


