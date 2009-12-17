From: Milan Broz <mbroz@redhat.com>
Date: Thu, 17 Dec 2009 14:49:06 +0100
Subject: [PATCH] Also clean up MISSING devices in --removemissing --force
In-Reply-To: <87iqc5g8vw.fsf@twilight.int.mornfall.net.>
References: <87iqc5g8vw.fsf@twilight.int.mornfall.net.>
Message-ID: <4B2A36D2.9090002@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On 12/17/2009 12:03 PM, Petr Rockai wrote:
> this is a simple patch that makes --removemissing --force treat
> MISSING_PV devices the same way as --removemissing (without --force)
> does. This should fix the last bit of RHBZ 537954.

> -		if (pvl->pv->dev)
> +		if (pvl->pv->dev && !(pvl->pv->status & MISSING_PV))
>  			continue;
>  		if (!_remove_pv(vg, pvl, 0))
>  			return_0;

ack.

Milan


