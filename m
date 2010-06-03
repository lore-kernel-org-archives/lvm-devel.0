From: brem belguebli <brem.belguebli@gmail.com>
Date: Thu, 3 Jun 2010 20:31:22 +0200
Subject: [PATCH] fix some issues in clvmd initscript
In-Reply-To: <4C079571.1050409@redhat.com>
References: <4BFD1B92.9080403@redhat.com> <4C07543C.5040908@redhat.com>
	<4C077B2B.5030206@redhat.com> <4C079571.1050409@redhat.com>
Message-ID: <AANLkTimKDciNUgF1sxYeoZDYLeAmCTqVOUlWtoksj7nr@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

just a suggestion, but, in case one wants to use clvm in a
active/passive maner, there is a problem with the way clvmd is
started, as it tries to activate all the clustered VG's whether or not
they're already active  on another node.

In case of active/passive setup, by the means of exclusive activation,
this activation returns an error  (as of LMV2.0.56, cf
https://bugzilla.redhat.com/show_bug.cgi?id=517900, errata
http://rhn.redhat.com/errata/RHBA-2010-0299.html)

Another scenario being, when using exclusive activation, the cluster
resources can be managed by a "custom" cluster resource script (cf
https://www.redhat.com/archives/linux-cluster/2009-June/msg00002.html),
the resource script fails to start as clvmd init script has already
activated the VG's.

My suggestion would be to be able to forbid (via an exclusion list)
clvmd init script to activate automatically what's in this blacklist.

Regards

Brem


2010/6/3 Fabio M. Di Nitto <fdinitto@redhat.com>:
> On 6/3/2010 11:51 AM, Milan Broz wrote:
>> On 06/03/2010 09:05 AM, Fabio M. Di Nitto wrote:
>>> On 5/26/2010 3:01 PM, Milan Broz wrote:
>>>> - if daemon is already running, do nothing (and not reactivate VGs)
>>>>
>>>> - always explicitly return exit code in reload()
>>>>
>>>> - fix restart() so it really tries full start & stop and returns exit code
>>>> ? if clvmd -S fails and also touch lockfile afterwards
>>>>
>>>> --- clvmd.old ? ? ? 2010-05-26 14:21:15.000000000 +0200
>>>> +++ clvmd ? 2010-05-26 14:55:17.671245376 +0200
>>>> @@ -63,11 +63,12 @@ rh_status_q() {
>>>>
>>>> ?start()
>>>> ?{
>>>> - ? if ! rh_status_q; then
>>>> - ? ? ? ? ? echo -n "Starting $DAEMON: "
>>>> - ? ? ? ? ? daemon $DAEMON $CLVMDOPTS || return $?
>>>> - ? ? ? ? ? echo
>>>> - ? fi
>>>> +
>>>> + ? rh_status_q && return 0
>>>> +
>>>> + ? echo -n "Starting $DAEMON: "
>>>> + ? daemon $DAEMON $CLVMDOPTS || return $?
>>>> + ? echo
>>>
>>> careful with this change as it modifies the behavior compared to the old
>>> init script.
>>
>> So you want reactivate LVs even if clvmd is already running?
>
> Let me get this right :) I don?t care either way. Whatever the team
> wants is fine. I am only noticing that this a behavior change vs the old
> init script.
>
> Fabio
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


