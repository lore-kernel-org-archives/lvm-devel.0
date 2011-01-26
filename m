From: Petr Rockai <prockai@redhat.com>
Date: Wed, 26 Jan 2011 15:06:15 +0100
Subject: [PATCH 02/17] Add supporting functions for metadata areas stored in format instance.
In-Reply-To: <4D3FF9BC.9080401@redhat.com> (Peter Rajnoha's message of "Wed,
	26 Jan 2011 11:38:52 +0100")
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
	<1295867048-21558-3-git-send-email-prajnoha@redhat.com>
	<87pqrlrune.fsf@twilight.int.mornfall.net.>
	<4D3FF9BC.9080401@redhat.com>
Message-ID: <874o8vr9kz.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter Rajnoha <prajnoha@redhat.com> writes:

>> parameter everywhere. I know that currently we keep the PV/VG/... IDs in
>> unterminated strings, but I am quite sure this is not a good idea. I
>> wouldn't expect it to be a *lot* of work to change things to keep a NULL
>> termination in there as well. Maybe in a followup patch?
>
> ..thing with PV id is that we store that as a "struct id" which internally
> is an array of integeres... Hmm, so you want to put another array item with
> 0 at the end?
>
> BTW, we also do this "convert_to_string" in the cache code... So yes, maybe
> it would be fine to clean this up somehow...

Well, I don't see a problem with making the array ID_LEN + 1 instead of
ID_LEN and storing a 0 element at the end. It's always used as a
character array anyway, and we can save significant amount of
boilerplate by having that 0 in there.

Yours,
   Petr


