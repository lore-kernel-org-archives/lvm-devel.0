From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 29 Jun 2015 16:49:57 +0200
Subject: udev cookie on DM_DEVICE_RELOAD
In-Reply-To: <20150629140220.GA1604@redhat.com>
References: <55914C1C.6050309@suse.de> <20150629140220.GA1604@redhat.com>
Message-ID: <55915B15.708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/29/2015 04:02 PM, Mike Snitzer wrote:
> On Mon, Jun 29 2015 at  9:46am -0400,
> Hannes Reinecke <hare@suse.de> wrote:
> 
>> Hi all,
>>
>> I've been debugging weird failures in multipathing, where 'multipath
>> -r' would occasionally incide libdevmapper to create
>> device nodes under /dev/mapper on it's own, instead of relying on
>> udev for doing so.
>> Looking in the logs, I've found:
>>
>> Jun 29 15:15:05 | libdevmapper: ioctl/libdm-iface.c(1725): dm reload
>> 3600508b4000cf1c300008000002b0000  NF   [16384] (*1)
>> Jun 29 15:15:05 | libdevmapper: ioctl/libdm-iface.c(1689): Cookie
>> value is not set while trying to call DM_DEVICE_RESUME ioctl.
>> Please, consider using libdevmapper's udev synchronisation interface
>> or disable it explicitly by calling dm_udev_set_sync_support(0).
>> Jun 29 15:15:05 | libdevmapper: ioctl/libdm-iface.c(1691): Switching
>> off device-mapper and all subsystem related udev rules. Falling back
>> to libdevmapper node creation.
>>
>> Okay, that'll explain it.
>> Then I've added a cookie to the call of DM_DEVICE_RELOAD, and
>> encountered a hang:
>> Jun 29 15:41:55 | 3600508b1001047395656543131580001: addmap [0
>> 143305920 multipath 1 queue_if_no_path 0 1 1 service-time 0 1 1 104:0 1]
>> Jun 29 15:41:55 | libdevmapper: libdm-common.c(2105): Udev cookie
>> 0xd4d7246 (semid 6062098) created
>> Jun 29 15:41:55 | libdevmapper: libdm-common.c(2125): Udev cookie
>> 0xd4d7246 (semid 6062098) incremented to 1
>> Jun 29 15:41:55 | libdevmapper: libdm-common.c(1997): Udev cookie
>> 0xd4d7246 (semid 6062098) incremented to 2
>> Jun 29 15:41:55 | libdevmapper: libdm-common.c(2238): Udev cookie
>> 0xd4d7246 (semid 6062098) assigned to RELOAD task(1) with flags
>> DISABLE_LIBRARY_FALLBACK (0x20)
>> Jun 29 15:41:55 | libdevmapper: ioctl/libdm-iface.c(1725): dm reload
>> 3600508b1001047395656543131580001  NNS    [16384] (*1)
>> Jun 29 15:41:55 | libdevmapper: libdm-common.c(2032): Udev cookie
>> 0xd4d7246 (semid 6062098) decremented to 1
>> Jun 29 15:41:55 | libdevmapper: libdm-common.c(2288): Udev cookie
>> 0xd4d7246 (semid 6062098) waiting for zero
>> (hangs)
>>
>> So apparently you can only set the cookie for DM_DEVICE_RESUME,
>> _not_ DM_DEVICE_RELOAD.
>>
>> Which is odd, as DM_DEVICE_RELOAD is the only call I'll ever do;
>> apparently it's being translated internally into a
>> suspend/reload/resume cycle.
>>
>> Shouldn't device-mapper take care of setting the cookie correctly?
> 
> This is really a question for the lvm2 developers (Alasdair and Peter
> Rajnoha specifically, cc'd).

Actually, we don't check proper combination of dm_task_set_cookie with
dm task type. So currently, if someone sets cookie on a task that does
not produce uevents, it can hang if dm_udev_wait is called for such cookie.

I've noticed we have a FIXME in the code for this already, but clearly
nobody has run into this issue yet. I'll add the check!

As for the DM_DEVICE_RELOAD - yes, it needs DM_DEVICE_RESUME to be called
right after the reload for the new table to be used (and hence the uevent
with the cookie generated as well). If you call RELOAD, the inactive
table is loaded which is then switched to active with the RESUME.

The task that is transparently translated into 3 tasks internally is the
DM_DEVICE_CREATE (with table) which translates into CREATE + LOAD + RESUME.

Anyway, yes, the check whether cookie is not misused is not there yet, so
that's why you hit this.

-- 
Peter


