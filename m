From: Thomas Lamprecht <t.lamprecht@proxmox.com>
Date: Tue, 3 Oct 2017 17:14:08 +0200
Subject: [RFC] dmeventd: ensure systemd service gets stopped on shutdown
In-Reply-To: <b910924e-d7a9-73f9-32a6-3422ec992a5c@redhat.com>
References: <20171002122636.20879-1-t.lamprecht@proxmox.com>
	<b910924e-d7a9-73f9-32a6-3422ec992a5c@redhat.com>
Message-ID: <d4c4afc8-0cdf-9d4d-a784-5d7b28f6cfa7@proxmox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/03/2017 03:12 PM, Peter Rajnoha wrote:
> On 10/02/2017 02:26 PM, Thomas Lamprecht wrote:
>> diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
>> index 7c607aaf2..a3284c810 100644
>> --- a/scripts/dm_event_systemd_red_hat.service.in
>> +++ b/scripts/dm_event_systemd_red_hat.service.in
>> @@ -4,6 +4,8 @@ Documentation=man:dmeventd(8)
>>  Requires=dm-event.socket
>>  After=dm-event.socket
>>  Before=local-fs-pre.target
>> +Before=shutdown.target
>> +Conflicts=shutdown.target
>>  DefaultDependencies=no
>>  
> 
> Hi!
> 
> Yes, we should be able to make cleaner ordering of these services. By
> design, the dm-event.service is supposed to be stopped after all the
> monitoring clients command dmeventd to unmonitor particular devices
> belonging to a subsystem (like LVM with "vgchange --monitor n" that is
> part of lvm2-monitor.service).
> 
> At this moment, we just let the dmeventd to get stopped/killed when the
> last SIGTERM signal is sent to all remaining processes on shutdown. But
> I agree it would be cleaner to do this as part of proper "service stop"
> action for dm-event.service (that would be executed as part of
> Conflicts: shutdown.target which you reference in your patch).
> 
> Unfortunately, there's a bug which we need to fix first for this to work
> correctly, I've filed it here:
> https://bugzilla.redhat.com/show_bug.cgi?id=1498080
> 

I'm running in exactly this bug for a while now quite consistently,
this was the cause for my initial investigation and also this patch.

As with the ordering enforced dm-eventd.service will be terminated
directly after lvm2-monitor.service instead of a bit later where
normal service termination is already finished.

I had initially also the idea for queuing the exit, i.e. set _exit_now
to 2 and log once that web could not exit immediately but exit is
scheduled and then wait for the next possible moment where we may
really exit. Optionally we could avoid running new threads if a exit
request is pending.

cheers,
Thomas


