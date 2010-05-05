From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 05 May 2010 16:30:45 +0200
Subject: [PATCH] Provide a new --sysinit switch for vgchange and lvchange
In-Reply-To: <878w7y1mtu.fsf@twilight.int.mornfall.net.>
References: <4BE16BD5.7030402@redhat.com>
	<878w7y1mtu.fsf@twilight.int.mornfall.net.>
Message-ID: <4BE18115.1030200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/05/2010 03:48 PM, Petr Rockai wrote:
> Peter Rajnoha <prajnoha@redhat.com> writes:
>> In read-only environment, we normally use the same bunch of switches
>> to disable several things (--ignoremonitoring, --ignorelockingfailure,
>> --poll n, LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1...) This is used
>> on system startup mainly. Maybe we could add a new switch that will
>> set everything automatically to make things a little bit cleaner and
>> more maintainable, so we don't have to bug people around to change
>> things if we need to add/change something (it could be used in
>> initscripts, dracut, anything similar...).
> I don't think one size fits all of the above. E.g. you want monitoring
> to be handled by initscripts but not by dracut.
> 

Well, both dracut and initscripts should have the same options/switches
used I think, including monitoring. Dracut already uses --ignoremonitoring
and rc.sysinit is about to change to include this one...

Peter


