From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 22 Sep 2015 13:30:03 +0200
Subject: [PATCHv2 2/4] dmeventd: Fix registration of existing thread
In-Reply-To: <1442920570-29969-3-git-send-email-mcsontos@redhat.com>
References: <1442920570-29969-1-git-send-email-mcsontos@redhat.com>
	<1442920570-29969-3-git-send-email-mcsontos@redhat.com>
Message-ID: <56013BBB.3000301@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/22/2015 01:16 PM, Marian Csontos wrote:
> The existing code is handling only new registrations correctly. Extending
> an existing registration does not register for timeout.
> ---
> If the condition should "never occur" we should either handle it or at least
> raise an internal error here as it is likely to occur one day without traces
> what happened.
>
> *TODO* Any ideas how to test this? Is explicitly messaging dmeventd required?
>
>   daemons/dmeventd/dmeventd.c | 18 ++++++++++++++++--
>   1 file changed, 16 insertions(+), 2 deletions(-)
>
> diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
> index 0f67206..ff11625 100644
> --- a/daemons/dmeventd/dmeventd.c
> +++ b/daemons/dmeventd/dmeventd.c
> @@ -1031,6 +1031,7 @@ static int _register_for_event(struct message_data *message_data)
>   	int ret = 0;
>   	struct thread_status *thread, *thread_new = NULL;
>   	struct dso_data *dso_data;
> +	enum dm_event_mask orig_events

Lost a semicolon while moving from below :-/

BTW, are we always declaring variables at the top of a function, right?

>
>   	if (!(dso_data = _lookup_dso(message_data)) &&
>   	    !(dso_data = _load_dso(message_data))) {
> @@ -1087,10 +1088,23 @@ static int _register_for_event(struct message_data *message_data)
>   		}
>
>   		LINK_THREAD(thread);
> +	} else {
> +		/* Or event # into events bitfield. */
> +		orig_events = thread->events;
> +		thread->events |= message_data->events_field;
> +		if ((~orig_events & thread->events & DM_EVENT_TIMEOUT)) {
> +			_unlock_mutex();
> +			if (!(ret = -_register_for_timeout(thread))) {
> +				/* In case previous calls failed we do not
> +				 * force unregister event. Reset events for
> +				 * consistency. */
> +				_lock_mutex();
> +				thread->events &= ~DM_EVENT_TIMEOUT;
> +			} else
> +				_lock_mutex();
> +		}
>   	}
>
> -	/* Or event # into events bitfield. */
> -	thread->events |= message_data->events_field;
>   	_unlock_mutex();
>
>         out:
>


