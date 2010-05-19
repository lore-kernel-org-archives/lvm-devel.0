From: Petr Rockai <prockai@redhat.com>
Date: Wed, 19 May 2010 22:26:43 +0200
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <4BF41C96.4090702@redhat.com> (Takahiro Yasui's message of "Wed, 
	19 May 2010 13:15:02 -0400")
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
	<87pr1kai2k.fsf@twilight.int.mornfall.net.>
	<87y6fxos3x.fsf@twilight.int.mornfall.net.>
	<4BEDD432.4010800@redhat.com> <4BF1CAD9.1050005@redhat.com>
	<87ljbg3xkt.fsf@twilight.int.mornfall.net.>
	<4BF41557.3040708@redhat.com> <4BF41C96.4090702@redhat.com>
Message-ID: <87vdaj3af0.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Taka,

Takahiro Yasui <tyasui@redhat.com> writes:

>>>> +	if (failed_mirrors) {
>>>> +		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, new_log_count,
>>>> +				       _is_partial_lv, NULL, 0))
>
> +        if (failed_mirrors || failed_log) {
> +                if (!lv_remove_mirrors(cmd, lv, failed_mirrors, failed_log,
> +                                       _is_partial_lv, NULL, 0)) {
>

if (failed_mirrors || failed_log) is actually the same (well, should be)
as if (1) at this point... Anyway, if you have seen my previous mail,
the thing that actually is required to be called every time is
_reload_lv, which does metadata writing. The lv_remove_mirrors call is
only needed if failed_mirrors is true, since _lv_update_log_type should
have already dealt with log. If failed_log is true, then new_log_count
is 0 for disklog mirrors in the _lv_update_log_type call.

This is all still broken for mirrored logs, but this is not completely
easy to fix, so I'll defer that for now.

Yours,
   Petr.

PS: failed_mirrors would probably be better called failed_images...


