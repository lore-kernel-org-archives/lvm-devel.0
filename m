From: Milan Broz <mbroz@redhat.com>
Date: Thu, 24 Mar 2011 13:53:57 +0100
Subject: [PATCH 4/4] Better shutdown for clvmd
In-Reply-To: <5826c97b6ad94b05ed1d57f34dc3d72db9b09a5b.1300965223.git.zkabelac@redhat.com>
References: <cover.1300965223.git.zkabelac@redhat.com>
	<5826c97b6ad94b05ed1d57f34dc3d72db9b09a5b.1300965223.git.zkabelac@redhat.com>
Message-ID: <4D8B3EE5.5090302@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/24/2011 12:16 PM, Zdenek Kabelac wrote:
> Ok - this is 'a small step' towards cleaner shutdown sequence.

(Yes it is small step. I would like just mention that we are not
walking on the Moon, but trying to move an elephant from porcelain
storage room.)

Btw there are 3 problems in this patch
- unrelated code tidy
- thread join
- fix memleak and close of descriptors


> -typedef void *(lvm_pthread_fn_t)(void*);
> +static void *lvm_thread_fn(void *);

> -	pthread_create(&lvm_thread, NULL, (lvm_pthread_fn_t*)lvm_thread_fn,
> -			(void *)&lvm_params);
> +	pthread_create(&lvm_thread, NULL, lvm_thread_fn, &lvm_params);

code tidying, please use separate patch for these next time,
so it is not mixed with real bugfixes... ;-)

> +	pthread_mutex_lock(&lvm_thread_mutex);
> +	pthread_cond_signal(&lvm_thread_cond);
> +	pthread_mutex_unlock(&lvm_thread_mutex);
> +	if ((errno = pthread_join(lvm_thread, NULL)))
> +		log_sys_error("pthread_join", "");

> @@ -1952,7 +1964,7 @@ static void lvm_thread_fn(void *arg)
>  	pthread_mutex_unlock(&lvm_start_mutex);
>  
>  	/* Now wait for some actual work */
> -	for (;;) {
> +	while (!quit) {

I hope I thought what can happen when there is still work in queue
and I think it is correctly handled...

ACK

> +	for (newfd = local_client_head.next; newfd != NULL;) {
> +		delfd = newfd;
> +		newfd = newfd->next;
> +		/* FIXME: needs cleanup code from read_from_local_sock() */
> +                /* for now break of CLVMD presents access to free memory here */
> +		safe_close(&(delfd->fd));
> +		free(delfd);
> +	}

Well, this looks safe. Everything should be stopped, so even there is FIXME still,
it fixes part of problem.

ACK

Milan


