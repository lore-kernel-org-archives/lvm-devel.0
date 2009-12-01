From: Milan Broz <mbroz@redhat.com>
Date: Tue, 01 Dec 2009 15:45:14 +0100
Subject: [PATCH] Give better message for pvmove when all data is skipped
In-Reply-To: <4B1526C4.2010900@redhat.com>
References: <4B1526C4.2010900@redhat.com>
Message-ID: <4B152BFA.5030904@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/01/2009 03:23 PM, Peter Rajnoha wrote:
> Just a little thing - better message in pvmove, maybe :) 
> BZ #500898/#500899

("mention skipped LVs in pvmove error message")

Ack.

> +			log_error("All data on source PV skipped. "
> +				  "It contains locked, hidden or "
> +				  "non-top level LVs only.");

This message probably need some better formulation (remove lvm internals?),
please contact our lvm language dept. ;-)

Milan
--
mbroz at redhat.com


