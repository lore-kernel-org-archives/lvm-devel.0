From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 3 Nov 2009 00:48:50 +0000
Subject: Re: [dm-devel] Segment fault in datastruct/hash.c
In-Reply-To: <1cafab770910272052v4a9ec931v893b4925dd0e2e12@mail.gmail.com>
References: <1cafab770910272052v4a9ec931v893b4925dd0e2e12@mail.gmail.com>
Message-ID: <20091103004850.GJ13375@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Oct 28, 2009 at 11:52:52AM +0800, Xinwei Hu wrote:
>   I generate a patch against the latest git tree. Please consider it
> for inclusion.
 
Applied.

> --- a/libdm/datastruct/hash.c
> +++ b/libdm/datastruct/hash.c
> @@ -143,9 +143,13 @@ static struct dm_hash_node **_find(struct dm_hash_table *t, const char *key,

> +		if ((*c)->keylen != len)
> +			continue
                                ^
(Did you try the patch?)

Alasdair


