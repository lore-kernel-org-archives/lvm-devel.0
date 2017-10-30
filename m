From: Eric Ren <zren@suse.com>
Date: Mon, 30 Oct 2017 18:22:10 +0800
Subject: [PATCH] lvconvert: fix wrong name order when merging thin snapshot
In-Reply-To: <ba22ed84-b3dc-0a88-f1ed-84e0fe51ee21@redhat.com>
References: <20171030044829.9564-1-zren@suse.com>
	<ba22ed84-b3dc-0a88-f1ed-84e0fe51ee21@redhat.com>
Message-ID: <e472a2a9-1d71-761d-2775-94274cbb0c05@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

>
> The only trouble here is that 'display_lvname()' is using internal 
> ring buffer inside cmd struct, so the output is meant to be used 
> immediately, otherwise
> it might get overwritten and you will get on output some garbage.
> So the proper solution here is to copy the string (dm_strncpy()) in
> a local buffer[NAME_LEN] buffer.

I considered fixing it in this way, but it seems using display_lvname() 
here is OK. I tested this patch,
which doesn't output garbage, and I see other places also do like this. 
So, I intended to save a
string copy.

> But I'll handle that one myself.
>
> Thanks for noticing.
No problem, but I'm thinking I can send patch v2 if it's a real problem...

Thanks,
Eric


