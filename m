From: Petr Rockai <prockai@redhat.com>
Date: Wed, 05 May 2010 09:46:55 +0200
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <4BD88E71.3040902@redhat.com> (Takahiro Yasui's message of "Wed, 
	28 Apr 2010 15:37:21 -0400")
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
	<4BD88E71.3040902@redhat.com>
Message-ID: <87pr1a3i4w.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Taka,

Takahiro Yasui <tyasui@redhat.com> writes:
> It is very grad that the patch to fix this issue was being developed.
> I have not thoroughly read it, but I found one issue. It doesn't work
> for a "mirrored" log, while it looks good for a "core" or "disk" log.
[snip]

this is not really an issue with the new code per se. What needs to be
done is that lvconvert --repair itself needs to be changed to handle
mirrored logs correctly.

What needs to be done is to call the repair recursively on the log
device if it is a mirror.

> The current code calls lv_check_transient() at the beginning of
> _lvconvert_mirrors_repair() but I think that lv_check_transient()
> needs to be called in functions which repairs a mirror log,
> such as _lv_update_log_type(), too.
(see above)

> Also this patch works well not only for a transient error but
> also a medium error, therefore, function names with '_transient'
> could be '_status' or '_status_string'. (e.g. lv_check_status())
I chose transient not because of "transient error", but because of the
relation to the transient, in-kernel, status of the device -- as opposed
to persistent, i.e. in metadata. Maybe something with "active" or
"activation" in it would be better though...

And, thanks for looking through the patch.

Yours,
   Petr.


