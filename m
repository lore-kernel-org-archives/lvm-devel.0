From: Milan Broz <mbroz@redhat.com>
Date: Sat, 26 Mar 2011 10:59:33 +0100
Subject: [PATCH 1/3] Fix mem
In-Reply-To: <e943c109d457bd2cc89c836ae810ec9b8c7bb8f3.1301089240.git.zkabelac@redhat.com>
References: <cover.1301089240.git.zkabelac@redhat.com>
	<e943c109d457bd2cc89c836ae810ec9b8c7bb8f3.1301089240.git.zkabelac@redhat.com>
Message-ID: <4D8DB905.7020100@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/25/2011 10:57 PM, Zdenek Kabelac wrote:

> -		unlock_and_free_vg(cmd, vg_from, vg_name_from);
> -		unlock_and_free_vg(cmd, vg_to, vg_name_to);
> +		unlock_vg(cmd, vg_name_from);
> +		unlock_vg(cmd, vg_name_to);
> +		free_vg(vg_to);
> +		free_vg(vg_from);

I guess there is still request to do proper deep copy...

Anyway, this is so simple and obvious for now -> ACK

Milan


