From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 15 Mar 2010 10:03:46 +0100
Subject: [PATCH] Use correct array size!
In-Reply-To: <8db1b9ee17a8c097a7b3.1268439437@localhost>
References: <8db1b9ee17a8c097a7b3.1268439437@localhost>
Message-ID: <4B9DF7F2.4010304@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 13.3.2010 01:17, Malahal Naineni wrote:
> Signed-off-by: Malahal Naineni (malahal at us.ibm.com)
> 
> diff -r 5d08ba4ae8e8 -r 8db1b9ee17a8 daemons/dmeventd/dmeventd.c
> --- a/daemons/dmeventd/dmeventd.c	Thu Mar 11 16:05:21 2010 -0800
> +++ b/daemons/dmeventd/dmeventd.c	Fri Mar 12 16:15:25 2010 -0800
> @@ -1369,7 +1369,7 @@ static int _handle_request(struct dm_eve
>  		{ DM_EVENT_CMD_ACTIVE, _active},
>  	}, *req;
>  
> -	for (req = requests; req < requests + sizeof(requests); req++)
> +	for (req = requests; req < requests + sizeof(requests) / sizeof(requests[0]); req++)
>  		if (req->cmd == msg->cmd)
>  			return req->f(message_data);


NACK

Moving via pointers - thus you need to check whether pointer passes
array boundary (just like C++ vector() iterator)

see the difference:
for(req = 0; i < sizeof(requests) / sizeof(requests[0]); req++0

Zdenek


